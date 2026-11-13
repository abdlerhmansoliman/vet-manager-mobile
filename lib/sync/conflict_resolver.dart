import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Status of a server acknowledgment for an outbound push mutation.
enum PushAckStatus {
  /// The mutation was cleanly applied on the backend.
  applied,

  /// The physical container was already depleted on the server; the backend
  /// automatically attributed the deduction to the next available container (FEFO spillover).
  reconciledWithSpillover,

  /// Total physical inventory was depleted; the server committed the audit record
  /// without rolling back and raised a high-priority discrepancy alert for the clinic owner.
  discrepancyLogged,

  /// Request rejected due to authorization or validation failure.
  rejected,
}

/// Server acknowledgment response payload for a single queued mutation.
class PushAckResult {
  final String mutationId;
  final String entityType;
  final String entityId;
  final PushAckStatus status;
  final String? newContainerId;
  final bool alertRaised;
  final String? message;

  const PushAckResult({
    required this.mutationId,
    required this.entityType,
    required this.entityId,
    required this.status,
    this.newContainerId,
    this.alertRaised = false,
    this.message,
  });

  factory PushAckResult.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString();
    PushAckStatus status;
    switch (statusStr) {
      case 'reconciled_with_spillover':
        status = PushAckStatus.reconciledWithSpillover;
        break;
      case 'discrepancy_logged':
        status = PushAckStatus.discrepancyLogged;
        break;
      case 'rejected':
        status = PushAckStatus.rejected;
        break;
      case 'applied':
      default:
        status = PushAckStatus.applied;
        break;
    }

    return PushAckResult(
      mutationId: json['mutation_id']?.toString() ?? json['id']?.toString() ?? '',
      entityType: json['entity_type']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      status: status,
      newContainerId: json['new_container_id']?.toString(),
      alertRaised: json['alert_raised'] == true,
      message: json['message']?.toString(),
    );
  }
}

/// Force-Reconcile & Immutable Append-Only Conflict Resolver.
///
/// Ambulatory veterinarians work in rural environments where offline collisions occur.
/// Core Invariants:
/// 1. Never Drop Clinical Records: Physical doses administered and signed vitals occurred.
///    They must NEVER be rolled back or discarded due to server version conflicts.
/// 2. Automatic FEFO Spillover: Reattributes depleted vial deductions to next available container.
/// 3. Discrepancy Flagging: Logs stock discrepancy alerts while preserving full ledger audit trails.
/// 4. Append-Only SOAP Notes: Medical progress notes and addenda are strictly additive.
class ConflictResolver {
  final AppDatabase db;

  ConflictResolver({required this.db});

  /// Processes server acknowledgment for an outbound mutation.
  Future<void> resolvePushAck(PushAckResult ack) async {
    final now = DateTime.now().toUtc();

    switch (ack.status) {
      case PushAckStatus.applied:
        await _markEntitySynced(ack.entityType, ack.entityId, now);
        break;

      case PushAckStatus.reconciledWithSpillover:
        // Force-Reconcile: Reattribute container reference in the immutable ledger
        if (ack.entityType == 'inventory_movement_ledger' || ack.entityType == 'dose') {
          await (db.update(db.inventoryMovementLedgerTable)
                ..where((l) => l.id.equals(ack.entityId)))
              .write(
            InventoryMovementLedgerTableCompanion(
              containerId: ack.newContainerId != null ? Value(ack.newContainerId) : const Value.absent(),
              notes: Value(
                ack.newContainerId != null
                    ? 'Reconciled with FEFO spillover to container: ${ack.newContainerId}'
                    : 'Reconciled with FEFO spillover',
              ),
              syncStatus: const Value('synced'),
              lastSyncedAt: Value(now),
            ),
          );
        } else {
          await _markEntitySynced(ack.entityType, ack.entityId, now);
        }
        break;

      case PushAckStatus.discrepancyLogged:
        // Force-Reconcile: Commit dose record and flag discrepancy alert
        if (ack.entityType == 'inventory_movement_ledger' || ack.entityType == 'dose') {
          await (db.update(db.inventoryMovementLedgerTable)
                ..where((l) => l.id.equals(ack.entityId)))
              .write(
            InventoryMovementLedgerTableCompanion(
              notes: const Value(
                'ALERT: Stock discrepancy flagged by server — physical offline dose committed',
              ),
              syncStatus: const Value('synced'),
              lastSyncedAt: Value(now),
            ),
          );
        } else {
          await _markEntitySynced(ack.entityType, ack.entityId, now);
        }
        break;

      case PushAckStatus.rejected:
        // Mutation rejected by server (e.g. visit locked/signed, or validation failed).
        if (ack.entityType == 'visit' || ack.entityType == 'visits') {
          await (db.update(db.visitsTable)..where((v) => v.id.equals(ack.entityId))).write(
            const VisitsTableCompanion(syncStatus: Value('failed')),
          );
        } else if (ack.entityType == 'clinical_progress_note' || ack.entityType == 'progress_note') {
          await (db.update(db.clinicalProgressNotesTable)..where((n) => n.id.equals(ack.entityId))).write(
            const ClinicalProgressNotesTableCompanion(syncStatus: Value('failed')),
          );
        }
        break;
    }
  }

  /// Marks a specific entity as synced in local SQLite tables.
  Future<void> _markEntitySynced(String entityType, String entityId, DateTime now) async {
    switch (entityType) {
      case 'client':
        await (db.update(db.clientsTable)..where((c) => c.id.equals(entityId))).write(
          ClientsTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;

      case 'patient':
        await (db.update(db.patientsTable)..where((p) => p.id.equals(entityId))).write(
          PatientsTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;

      case 'clinical_case':
      case 'case':
        await (db.update(db.clinicalCasesTable)..where((c) => c.id.equals(entityId))).write(
          ClinicalCasesTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;

      case 'visit':
      case 'visits':
        await (db.update(db.visitsTable)..where((v) => v.id.equals(entityId))).write(
          const VisitsTableCompanion(syncStatus: Value('synced')),
        );
        break;

      case 'clinical_progress_note':
      case 'progress_note':
        await (db.update(db.clinicalProgressNotesTable)..where((n) => n.id.equals(entityId))).write(
          const ClinicalProgressNotesTableCompanion(syncStatus: Value('synced')),
        );
        break;

      case 'diagnosis':
        await (db.update(db.diagnosesTable)..where((d) => d.id.equals(entityId))).write(
          const DiagnosesTableCompanion(syncStatus: Value('synced')),
        );
        break;

      case 'inventory_movement_ledger':
      case 'dose':
        await (db.update(db.inventoryMovementLedgerTable)..where((l) => l.id.equals(entityId))).write(
          InventoryMovementLedgerTableCompanion(syncStatus: const Value('synced'), lastSyncedAt: Value(now)),
        );
        break;
    }
  }

  /// Safely ingests inbound server deltas into Drift relational tables.
  /// Enforces Append-Only invariant for SOAP progress notes and addenda.
  Future<void> applyServerDeltas({
    required String tenantId,
    required Map<String, dynamic> deltas,
  }) async {
    final now = DateTime.now().toUtc();

    await db.transaction(() async {
      // 1. Clients
      if (deltas['clients'] is List) {
        for (final item in deltas['clients'] as List) {
          if (item is Map<String, dynamic>) {
            await db.into(db.clientsTable).insertOnConflictUpdate(
                  ClientsTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    name: Value(item['name']?.toString() ?? 'Client'),
                    phonePrimary: Value(item['phone_primary']?.toString() ?? '000-000-0000'),
                    phoneSecondary: Value(item['phone_secondary']?.toString()),
                    clientType: Value(item['client_type']?.toString() ?? 'individual'),
                    physicalAddress: Value(item['physical_address']?.toString()),
                    notes: Value(item['notes']?.toString()),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse(item['deleted_at']?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 2. Patients
      if (deltas['patients'] is List) {
        for (final item in deltas['patients'] as List) {
          if (item is Map<String, dynamic>) {
            final clientId = item['client_id']?.toString() ?? '';
            if (clientId.isEmpty) continue;

            final clientExists = await (db.select(db.clientsTable)..where((c) => c.id.equals(clientId))).getSingleOrNull();
            if (clientExists == null) {
              await db.into(db.clientsTable).insert(
                ClientsTableCompanion(
                  id: Value(clientId),
                  tenantId: Value(tenantId),
                  name: const Value('Unknown Client'),
                  phonePrimary: const Value('000-000-0000'),
                  clientType: const Value('individual'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }

            final weightRaw = item['current_weight_kg'];
            double? parsedWeight;
            if (weightRaw is num) {
              parsedWeight = weightRaw.toDouble();
            } else if (weightRaw is String) {
              parsedWeight = double.tryParse(weightRaw);
            }

            final ageRaw = item['age'];
            int? parsedAge;
            if (ageRaw is int) {
              parsedAge = ageRaw;
            } else if (ageRaw is num) {
              parsedAge = ageRaw.toInt();
            } else if (ageRaw is String) {
              parsedAge = int.tryParse(ageRaw);
            }

            await db.into(db.patientsTable).insertOnConflictUpdate(
                  PatientsTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    clientId: Value(clientId),
                    nameOrTag: Value(item['name_or_tag']?.toString() ?? 'Unknown'),
                    species: Value(item['species']?.toString() ?? 'Canine'),
                    breed: Value(item['breed']?.toString()),
                    gender: Value(item['gender']?.toString() ?? 'unknown'),
                    age: Value(parsedAge),
                    dateOfBirth: Value(DateTime.tryParse(item['date_of_birth']?.toString() ?? '')),
                    isApproximateAge: Value(item['is_approximate_age'] == 1 || item['is_approximate_age'] == true),
                    microchipNumber: Value(item['microchip_number']?.toString()),
                    earTagId: Value(item['ear_tag_id']?.toString()),
                    coatColorMarkings: Value(item['coat_color_markings']?.toString()),
                    currentWeightKg: Value(parsedWeight),
                    weightRecordedAt: Value(DateTime.tryParse(item['weight_recorded_at']?.toString() ?? '')),
                    history: Value(item['history']?.toString()),
                    notes: Value(item['notes']?.toString()),
                    allergies: Value(item['allergies'] != null ? jsonEncode(item['allergies']) : null),
                    status: Value(item['status']?.toString() ?? 'active'),
                    deceasedAt: Value(DateTime.tryParse(item['deceased_at']?.toString() ?? '')),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse(item['deleted_at']?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 3. Clinical Cases
      if (deltas['cases'] is List) {
        for (final item in deltas['cases'] as List) {
          if (item is Map<String, dynamic>) {
            final patientId = item['patient_id']?.toString() ?? '';
            if (patientId.isEmpty) continue;

            final patientExists = await (db.select(db.patientsTable)..where((p) => p.id.equals(patientId))).getSingleOrNull();
            if (patientExists == null) {
              const fallbackClientId = '00000000-0000-0000-0000-000000000000';
              await db.into(db.clientsTable).insert(
                ClientsTableCompanion(
                  id: const Value(fallbackClientId),
                  tenantId: Value(tenantId),
                  name: const Value('Unknown Client'),
                  phonePrimary: const Value('000-000-0000'),
                  clientType: const Value('individual'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );
              await db.into(db.patientsTable).insert(
                PatientsTableCompanion(
                  id: Value(patientId),
                  tenantId: Value(tenantId),
                  clientId: const Value(fallbackClientId),
                  nameOrTag: const Value('Unknown Patient'),
                  species: const Value('Canine'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }

            await db.into(db.clinicalCasesTable).insertOnConflictUpdate(
                  ClinicalCasesTableCompanion(
                    id: Value(item['id'] as String),
                    tenantId: Value(tenantId),
                    caseNumber: Value(item['case_number']?.toString() ?? 'CAS-UNKNOWN'),
                    patientId: Value(patientId),
                    primaryVeterinarianId: Value(item['primary_veterinarian_id']?.toString() ?? ''),
                    primaryVeterinarianName: Value(item['primary_veterinarian_name']?.toString()),
                    caseType: Value(item['case_type']?.toString() ?? 'outpatient'),
                    chiefComplaint: Value(item['chief_complaint']?.toString() ?? 'General Consultation'),
                    provisionalDiagnosis: Value(item['provisional_diagnosis']?.toString()),
                    finalDiagnosis: Value(item['final_diagnosis']?.toString()),
                    priority: Value(
                      (item['priority']?.toString() ?? 'routine').toLowerCase() == 'emergency_critical'
                          ? 'critical'
                          : (item['priority']?.toString() ?? 'routine'),
                    ),
                    status: Value(item['status']?.toString() ?? 'open'),
                    admittedAt: Value(DateTime.tryParse(item['admitted_at']?.toString() ?? '') ?? now),
                    dischargedAt: Value(DateTime.tryParse(item['discharged_at']?.toString() ?? '')),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse(item['deleted_at']?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 4. Clinical Visits
      if (deltas['visits'] is List) {
        for (final item in deltas['visits'] as List) {
          if (item is Map<String, dynamic>) {
            final visitId = item['id']?.toString() ?? '';
            final caseId = item['case_id']?.toString() ?? '';
            if (visitId.isEmpty || caseId.isEmpty) continue;

            final caseExists = await (db.select(db.clinicalCasesTable)..where((c) => c.id.equals(caseId))).getSingleOrNull();
            if (caseExists == null) continue;

            await db.into(db.visitsTable).insertOnConflictUpdate(
                  VisitsTableCompanion(
                    id: Value(visitId),
                    tenantId: Value(tenantId),
                    caseId: Value(caseId),
                    patientId: Value(caseExists.patientId),
                    veterinarianId: Value(caseExists.primaryVeterinarianId),
                    veterinarianName: Value(caseExists.primaryVeterinarianName ?? 'Attending Clinician'),
                    title: Value(item['title']?.toString() ?? 'Visit'),
                    visitType: Value(item['visit_type']?.toString() ?? 'consultation'),
                    status: Value(item['status']?.toString() ?? 'open'),
                    isSigned: Value(item['is_signed'] == 1 || item['is_signed'] == true),
                    signedAt: Value(DateTime.tryParse(item['signed_at']?.toString() ?? '')),
                    signedBy: Value(item['signed_by']?.toString()),
                    visitDate: Value(DateTime.tryParse(item['visit_date']?.toString() ?? '') ?? now),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse(item['deleted_at']?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                  ),
                );
          }
        }
      }

      // 5. Clinical Progress Notes (Append-Only: never overwrite signed clinical notes)
      if (deltas['progress_notes'] is List) {
        for (final item in deltas['progress_notes'] as List) {
          if (item is Map<String, dynamic>) {
            final noteId = item['id']?.toString();
            if (noteId == null || noteId.isEmpty) continue;

            final caseId = (item['case_id'] ?? item['clinical_case_id'])?.toString() ?? '';
            if (caseId.isEmpty) continue;

            final caseRow = await (db.select(db.clinicalCasesTable)..where((c) => c.id.equals(caseId))).getSingleOrNull();
            if (caseRow == null) continue;

            final existing = await (db.select(db.clinicalProgressNotesTable)
                  ..where((n) => n.id.equals(noteId)))
                .getSingleOrNull();

            if (existing == null) {
              final patientId = item['patient_id']?.toString() ?? caseRow.patientId;
              final vetId = (item['veterinarian_id'] ?? item['vet_id'])?.toString() ?? caseRow.primaryVeterinarianId;
              final vetName = item['veterinarian_name']?.toString() ?? 'Attending Clinician';
              final noteType = item['note_type']?.toString() ?? 'soap';

              final subjective = item['subjective']?.toString() ?? item['subjective_notes']?.toString();
              final objective = item['objective']?.toString() ?? item['objective_notes']?.toString();
              final assessment = item['assessment']?.toString() ?? item['assessment_notes']?.toString();
              final plan = item['plan']?.toString() ?? item['plan_notes']?.toString();

              double? tempC;
              final tempRaw = item['temperature_c'] ?? item['temperature_celsius'];
              if (tempRaw is num) {
                tempC = tempRaw.toDouble();
              } else if (tempRaw is String) {
                tempC = double.tryParse(tempRaw);
              }

              int? hr;
              final hrRaw = item['heart_rate_bpm'];
              if (hrRaw is int) {
                hr = hrRaw;
              } else if (hrRaw is num) {
                hr = hrRaw.toInt();
              } else if (hrRaw is String) {
                hr = int.tryParse(hrRaw);
              }

              int? rr;
              final rrRaw = item['respiratory_rate'] ?? item['respiratory_rate_bpm'];
              if (rrRaw is int) {
                rr = rrRaw;
              } else if (rrRaw is num) {
                rr = rrRaw.toInt();
              } else if (rrRaw is String) {
                rr = int.tryParse(rrRaw);
              }

              await db.into(db.clinicalProgressNotesTable).insert(
                    ClinicalProgressNotesTableCompanion(
                      id: Value(noteId),
                      caseId: Value(caseId),
                      visitId: Value(item['visit_id']?.toString()),
                      patientId: Value(patientId),
                      veterinarianId: Value(vetId),
                      veterinarianName: Value(vetName),
                      noteType: Value(noteType),
                      subjective: Value(subjective),
                      objective: Value(objective),
                      assessment: Value(assessment),
                      plan: Value(plan),
                      temperatureCelsius: Value(tempC),
                      heartRateBpm: Value(hr),
                      respiratoryRateBpm: Value(rr),
                      recordedAt: Value(DateTime.tryParse(item['recorded_at']?.toString() ?? '') ?? DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                      createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                      updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                      syncStatus: const Value('synced'),
                    ),
                  );
            }
          }
        }
      }

      // 5. Inventory Products
      if (deltas['inventory_products'] is List) {
        for (final item in deltas['inventory_products'] as List) {
          if (item is Map<String, dynamic>) {
            final productId = item['id']?.toString() ?? '';
            if (productId.isEmpty) continue;

            await db.into(db.inventoryProductsTable).insertOnConflictUpdate(
                  InventoryProductsTableCompanion(
                    id: Value(productId),
                    tenantId: Value(tenantId),
                    sku: Value(item['sku']?.toString() ?? 'SKU-UNKNOWN'),
                    name: Value(item['name']?.toString() ?? 'Product'),
                    description: Value(item['description']?.toString() ?? item['package_description']?.toString()),
                    baseUnit: Value(item['base_unit']?.toString() ?? 'ml'),
                    isControlled: Value(item['is_controlled'] == 1 || item['is_controlled'] == true),
                    controlledSchedule: Value(item['controlled_schedule']?.toString()),
                    currentStockQty: Value(Decimal.tryParse(item['current_stock_qty']?.toString() ?? '0') ?? Decimal.zero),
                    minThreshold: Value(Decimal.tryParse((item['min_threshold'] ?? item['reorder_threshold'])?.toString() ?? '0') ?? Decimal.zero),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse(item['deleted_at']?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 6. Inventory Batches
      if (deltas['inventory_batches'] is List) {
        for (final item in deltas['inventory_batches'] as List) {
          if (item is Map<String, dynamic>) {
            final batchId = item['id']?.toString() ?? '';
            final productId = item['product_id']?.toString() ?? '';
            if (batchId.isEmpty || productId.isEmpty) continue;

            final productExists = await (db.select(db.inventoryProductsTable)..where((p) => p.id.equals(productId))).getSingleOrNull();
            if (productExists == null) {
              await db.into(db.inventoryProductsTable).insert(
                InventoryProductsTableCompanion(
                  id: Value(productId),
                  tenantId: Value(tenantId),
                  sku: const Value('SKU-AUTO'),
                  name: const Value('Unknown Product'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }

            final lotNumber = (item['lot_number'] ?? item['batch_number'])?.toString() ?? 'BATCH-001';
            final expiresAt = DateTime.tryParse((item['expires_at'] ?? item['expiration_date'])?.toString() ?? '') ?? now.add(const Duration(days: 365));

            await db.into(db.inventoryBatchesTable).insertOnConflictUpdate(
                  InventoryBatchesTableCompanion(
                    id: Value(batchId),
                    tenantId: Value(tenantId),
                    productId: Value(productId),
                    lotNumber: Value(lotNumber),
                    expiresAt: Value(expiresAt),
                    unitCost: Value(Decimal.tryParse((item['unit_cost'] ?? item['cost_per_base_unit'])?.toString() ?? '0') ?? Decimal.zero),
                    initialBaseQty: Value(Decimal.tryParse((item['initial_base_qty'] ?? item['initial_quantity'])?.toString() ?? '0') ?? Decimal.zero),
                    remainingBaseQty: Value(Decimal.tryParse((item['remaining_base_qty'] ?? item['remaining_quantity'])?.toString() ?? '0') ?? Decimal.zero),
                    status: Value(item['status']?.toString() ?? 'active'),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse(item['deleted_at']?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }

      // 7. Inventory Containers
      if (deltas['inventory_containers'] is List) {
        for (final item in deltas['inventory_containers'] as List) {
          if (item is Map<String, dynamic>) {
            final containerId = item['id']?.toString() ?? '';
            final batchId = item['batch_id']?.toString() ?? '';
            final productId = item['product_id']?.toString() ?? '';
            if (containerId.isEmpty || batchId.isEmpty || productId.isEmpty) continue;

            final productExists = await (db.select(db.inventoryProductsTable)..where((p) => p.id.equals(productId))).getSingleOrNull();
            if (productExists == null) {
              await db.into(db.inventoryProductsTable).insert(
                InventoryProductsTableCompanion(
                  id: Value(productId),
                  tenantId: Value(tenantId),
                  sku: const Value('SKU-AUTO'),
                  name: const Value('Unknown Product'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }

            final batchExists = await (db.select(db.inventoryBatchesTable)..where((b) => b.id.equals(batchId))).getSingleOrNull();
            if (batchExists == null) {
              await db.into(db.inventoryBatchesTable).insert(
                InventoryBatchesTableCompanion(
                  id: Value(batchId),
                  tenantId: Value(tenantId),
                  productId: Value(productId),
                  lotNumber: const Value('BATCH-AUTO'),
                  expiresAt: Value(now.add(const Duration(days: 365))),
                  initialBaseQty: Value(Decimal.zero),
                  remainingBaseQty: Value(Decimal.zero),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );
            }

            final barcode = (item['barcode'] ?? item['container_identifier'])?.toString() ?? containerId;

            await db.into(db.inventoryContainersTable).insertOnConflictUpdate(
                  InventoryContainersTableCompanion(
                    id: Value(containerId),
                    tenantId: Value(tenantId),
                    batchId: Value(batchId),
                    productId: Value(productId),
                    barcode: Value(barcode),
                    initialVolume: Value(Decimal.tryParse((item['initial_volume'] ?? item['initial_base_quantity'])?.toString() ?? '0') ?? Decimal.zero),
                    remainingBalance: Value(Decimal.tryParse((item['remaining_balance'] ?? item['current_base_balance'])?.toString() ?? '0') ?? Decimal.zero),
                    status: Value(item['status']?.toString() ?? 'sealed'),
                    openedAt: Value(DateTime.tryParse(item['opened_at']?.toString() ?? '')),
                    openedByUserId: Value(item['opened_by_user_id']?.toString()),
                    createdAt: Value(DateTime.tryParse(item['created_at']?.toString() ?? '') ?? now),
                    updatedAt: Value(DateTime.tryParse(item['updated_at']?.toString() ?? '') ?? now),
                    deletedAt: Value(DateTime.tryParse((item['deleted_at'] ?? item['depleted_at'])?.toString() ?? '')),
                    syncStatus: const Value('synced'),
                    lastSyncedAt: Value(now),
                  ),
                );
          }
        }
      }
    });
  }
}
