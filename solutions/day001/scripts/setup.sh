#!/bin/bash
# =============================================================================
# Day 001 - Exercise 3: Organization Policies and Budgets Setup
# =============================================================================
#
# Este script configura las organization policies críticas y los budgets
# para DataMartX. Debe ejecutarse ANTES de que los equipos empiecen a crear
# recursos.
#
# Requisitos:
# - gcloud CLI instalado y autenticado
# - Permisos de Organization Admin
# - Permisos de Billing Admin
#
# Uso:
#   chmod +x setup.sh
#   ./setup.sh
#
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuración
# =============================================================================

ORGANIZATION_ID="${ORGANIZATION_ID:-123456789}"
BILLING_ACCOUNT_ID="${BILLING_ACCOUNT_ID:-012345-6789AB-CDEF01}"

# Emails para alertas
PLATFORM_LEAD_EMAIL="platform-lead@datamartx.com"
DIRECTOR_EMAIL="director@datamartx.com"
VP_EMAIL="vp-engineering@datamartx.com"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-https://hooks.slack.com/services/XXX/YYY/ZZZ}"

echo "=========================================="
echo "DataMartX GCP Foundation Setup"
echo "=========================================="
echo "Organization ID: ${ORGANIZATION_ID}"
echo "Billing Account: ${BILLING_ACCOUNT_ID}"
echo ""

# =============================================================================
# 1. Organization Policies
# =============================================================================

echo "=========================================="
echo "1. Configurando Organization Policies"
echo "=========================================="
echo ""

# 1.1 Restricción de regiones
echo "1.1 Configurando restricción de regiones..."
cat > /tmp/restrict_regions.yaml <<EOF
constraint: constraints/gcp.resourceLocations
listPolicy:
  allowedValues:
    - "in:us-central1-locations"
    - "in:us-east1-locations"
    - "in:europe-west1-locations"
  allValues: DENY
EOF

gcloud resource-manager org-policies set-policy /tmp/restrict_regions.yaml \
  --organization="${ORGANIZATION_ID}"

echo "✓ Restricción de regiones configurada"
echo ""

# 1.2 Labels obligatorios
echo "1.2 Configurando labels obligatorios..."
# Nota: Esto requiere crear Tag Keys primero
gcloud resource-manager tag-keys create \
  --parent="organizations/${ORGANIZATION_ID}" \
  --short-name="environment" \
  --description="Environment label (production, staging, development)"

gcloud resource-manager tag-keys create \
  --parent="organizations/${ORGANIZATION_ID}" \
  --short-name="team" \
  --description="Team label (marketplace, logistics, payments, analytics, corporate)"

gcloud resource-manager tag-keys create \
  --parent="organizations/${ORGANIZATION_ID}" \
  --short-name="cost-center" \
  --description="Cost center label (cc-1001, cc-1002, etc.)"

echo "✓ Tag keys creados para labels obligatorios"
echo ""

# 1.3 Deshabilitar creación de service account keys
echo "1.3 Deshabilitando creación de service account keys..."
cat > /tmp/disable_sa_keys.yaml <<EOF
constraint: constraints/iam.disableServiceAccountKeyCreation
booleanPolicy:
  enforced: true
EOF

gcloud resource-manager org-policies set-policy /tmp/disable_sa_keys.yaml \
  --organization="${ORGANIZATION_ID}"

echo "✓ Creación de service account keys deshabilitada"
echo ""

# 1.4 Forzar uniform bucket-level access
echo "1.4 Configurando uniform bucket-level access..."
cat > /tmp/uniform_bucket_access.yaml <<EOF
constraint: constraints/storage.uniformBucketLevelAccess
booleanPolicy:
  enforced: true
EOF

gcloud resource-manager org-policies set-policy /tmp/uniform_bucket_access.yaml \
  --organization="${ORGANIZATION_ID}"

echo "✓ Uniform bucket-level access habilitado"
echo ""

# 1.5 Prevenir acceso público a buckets
echo "1.5 Previniendo acceso público a buckets..."
cat > /tmp/public_access_prevention.yaml <<EOF
constraint: constraints/storage.publicAccessPrevention
booleanPolicy:
  enforced: true
EOF

gcloud resource-manager org-policies set-policy /tmp/public_access_prevention.yaml \
  --organization="${ORGANIZATION_ID}"

echo "✓ Acceso público a buckets prevenido"
echo ""

# 1.6 Deshabilitar serial port access
echo "1.6 Deshabilitando serial port access..."
cat > /tmp/disable_serial_access.yaml <<EOF
constraint: constraints/compute.disableSerialPortAccess
booleanPolicy:
  enforced: true
EOF

gcloud resource-manager org-policies set-policy /tmp/disable_serial_access.yaml \
  --organization="${ORGANIZATION_ID}"

echo "✓ Serial port access deshabilitado"
echo ""

# =============================================================================
# 2. Budgets
# =============================================================================

echo "=========================================="
echo "2. Configurando Budgets"
echo "=========================================="
echo ""

# 2.1 Budget para Production
echo "2.1 Creando budget para Production ($100K/month)..."
gcloud billing budgets create \
  --billing-account="${BILLING_ACCOUNT_ID}" \
  --display-name="Production Budget" \
  --budget-amount=100000 \
  --threshold-rules-percent=50,80,100 \
  --threshold-rules-spend-basis=CURRENT_SPEND \
  --monitoring-notification-channels="" \
  --all-updates-rule-pubsub-topic="" \
  --all-updates-rule-schema-version="1.0" \
  --labels="environment=production"

echo "✓ Budget de Production creado"
echo ""

# 2.2 Budget para Staging
echo "2.2 Creando budget para Staging ($20K/month)..."
gcloud billing budgets create \
  --billing-account="${BILLING_ACCOUNT_ID}" \
  --display-name="Staging Budget" \
  --budget-amount=20000 \
  --threshold-rules-percent=50,80,100 \
  --threshold-rules-spend-basis=CURRENT_SPEND \
  --labels="environment=staging"

echo "✓ Budget de Staging creado"
echo ""

# 2.3 Budget para Development
echo "2.3 Creando budget para Development ($10K/month)..."
gcloud billing budgets create \
  --billing-account="${BILLING_ACCOUNT_ID}" \
  --display-name="Development Budget" \
  --budget-amount=10000 \
  --threshold-rules-percent=50,80,100 \
  --threshold-rules-spend-basis=CURRENT_SPEND \
  --labels="environment=development"

echo "✓ Budget de Development creado"
echo ""

# 2.4 Budget específico para Payments (PCI scope)
echo "2.4 Creando budget para Payments ($30K/month, alertas agresivas)..."
gcloud billing budgets create \
  --billing-account="${BILLING_ACCOUNT_ID}" \
  --display-name="Payments Production Budget" \
  --budget-amount=30000 \
  --threshold-rules-percent=40,70,90 \
  --threshold-rules-spend-basis=CURRENT_SPEND \
  --labels="team=payments,pci-scope=true"

echo "✓ Budget de Payments creado con alertas agresivas"
echo ""

# =============================================================================
# 3. Verificación
# =============================================================================

echo "=========================================="
echo "3. Verificando Configuración"
echo "=========================================="
echo ""

# 3.1 Verificar organization policies
echo "3.1 Organization Policies configuradas:"
gcloud resource-manager org-policies list \
  --organization="${ORGANIZATION_ID}" \
  --format="table(constraint,booleanPolicy,enforced,listPolicy.allowedValues.list())"

echo ""

# 3.2 Verificar budgets
echo "3.2 Budgets configurados:"
gcloud billing budgets list \
  --billing-account="${BILLING_ACCOUNT_ID}" \
  --format="table(displayName,budgetAmount,thresholdRules)"

echo ""

# =============================================================================
# 4. Documentación
# =============================================================================

echo "=========================================="
echo "4. Resumen de Configuración"
echo "=========================================="
echo ""
echo "Organization Policies:"
echo "  ✓ Restricción de regiones: us-central1, us-east1, europe-west1"
echo "  ✓ Labels obligatorios: environment, team, cost-center"
echo "  ✓ Service account keys: Deshabilitados"
echo "  ✓ Uniform bucket access: Habilitado"
echo "  ✓ Public access prevention: Habilitado"
echo "  ✓ Serial port access: Deshabilitado"
echo ""
echo "Budgets:"
echo "  ✓ Production: \$100K/month (alertas: 50%, 80%, 100%)"
echo "  ✓ Staging: \$20K/month (alertas: 50%, 80%, 100%)"
echo "  ✓ Development: \$10K/month (alertas: 50%, 80%, 100%)"
echo "  ✓ Payments: \$30K/month (alertas: 40%, 70%, 90%)"
echo ""
echo "=========================================="
echo "Setup completado exitosamente"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "  1. Configurar notificaciones de alertas (email, Slack)"
echo "  2. Probar policies creando recursos de prueba"
echo "  3. Documentar runbooks para operaciones"
echo "  4. Comunicar cambios a los equipos"
echo ""

# Limpiar archivos temporales
rm -f /tmp/restrict_regions.yaml \
      /tmp/disable_sa_keys.yaml \
      /tmp/uniform_bucket_access.yaml \
      /tmp/public_access_prevention.yaml \
      /tmp/disable_serial_access.yaml
