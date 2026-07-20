# Day 001 Solution - Architecture Design

## Diagrama de Arquitectura

```
Organization: datamartx.com (ID: 123456789)
│
├── Folder: Shared Services (ID: 111111111)
│   ├── Project: networking-shared
│   │   └── Shared VPC Host, Cloud DNS, Cloud NAT
│   ├── Project: security-shared
│   │   └── KMS, Secret Manager, SCC
│   └── Project: logging-shared
│       └── Centralized logging, Audit logs
│
├── Folder: Production (ID: 222222222)
│   ├── Folder: Marketplace (ID: 333333333)
│   │   ├── Project: marketplace-prod-us
│   │   │   └── Labels: env=prod, team=marketplace, region=us, cost-center=cc-1001
│   │   └── Project: marketplace-prod-eu
│   │       └── Labels: env=prod, team=marketplace, region=eu, cost-center=cc-1001
│   │
│   ├── Folder: Logistics (ID: 444444444)
│   │   └── Project: logistics-prod
│   │       └── Labels: env=prod, team=logistics, region=us, cost-center=cc-1002
│   │
│   ├── Folder: Payments (ID: 555555555) [PCI Scope]
│   │   └── Project: payments-prod
│   │       └── Labels: env=prod, team=payments, pci-scope=true, cost-center=cc-1003
│   │
│   ├── Folder: Analytics (ID: 666666666)
│   │   └── Project: analytics-prod
│   │       └── Labels: env=prod, team=analytics, region=us, cost-center=cc-1004
│   │
│   └── Folder: Corporate (ID: 777777777)
│       └── Project: corporate-prod
│           └── Labels: env=prod, team=corporate, region=us, cost-center=cc-1005
│
├── Folder: Staging (ID: 888888888)
│   ├── Project: marketplace-staging
│   ├── Project: logistics-staging
│   ├── Project: payments-staging
│   ├── Project: analytics-staging
│   └── Project: corporate-staging
│
└── Folder: Development (ID: 999999999)
    └── Project: shared-dev
        └── Labels: env=dev, team=shared, cost-center=cc-9999
```

## Justificación de Decisiones

### 1. Estructura de Folders: Híbrida (Ambiente + Línea de Negocio)

**Decisión:** Folders por ambiente en el primer nivel, luego por línea de negocio.

**Justificación:**
- **Producción vs Non-Production:** Requieren políticas diferentes (ej: regiones permitidas, backup policies)
- **Líneas de negocio en producción:** Necesitan aislamiento para:
  - Chargeback de costos
  - IAM policies específicas
  - Organization policies por compliance (PCI para Payments)
- **Staging/Development:** No necesitan sub-folders por línea de negocio porque:
  - Menos proyectos
  - Mismo equipo puede manejar múltiples líneas
  - Reduce complejidad

**Trade-offs:**
- ✅ Aislamiento claro entre ambientes
- ✅ Chargeback por línea de negocio en producción
- ✅ PCI scope claramente definido
- ⚠️ Más folders que gestionar (pero vale la pena)
- ❌ No es la estructura más simple (pero sí la más escalable)

### 2. Proyectos: One-per-Application-per-Region

**Decisión:** Proyectos separados por aplicación y región.

**Justificación:**
- **Marketplace:** 2 proyectos (US + EU) porque:
  - GDPR requiere datos de EU en EU
  - Latencia: usuarios EU no deberían ir a US
  - Aislamiento de blast radius
- **Payments:** 1 proyecto porque:
  - PCI scope debe estar claramente definido
  - Todo el proyecto está en scope
  - Más fácil de auditar
- **Development:** 1 proyecto compartido porque:
  - Bajo riesgo
  - Costos mínimos
  - Facilita colaboración

**Trade-offs:**
- ✅ Aislamiento de compliance (PCI, GDPR)
- ✅ Chargeback granular
- ✅ Blast radius limitado
- ⚠️ Más proyectos que gestionar (~15 proyectos)
- ❌ Overhead de APIs habilitadas por proyecto

### 3. Estrategia de Naming

**Patrón:** `{line-of-business}-{environment}-{region}`

**Ejemplos:**
- `marketplace-prod-us`
- `payments-prod` (sin región porque es global)
- `marketplace-staging` (sin región porque staging es único)

**Justificación:**
- Consistente y predecible
- Facilita búsqueda y filtering
- Claro para nuevos ingenieros
- Escala a 200+ proyectos

### 4. Labels Obligatorios

**Labels requeridos:**
```yaml
environment: production | staging | development
team: marketplace | logistics | payments | analytics | corporate
cost-center: cc-1001 | cc-1002 | cc-1003 | cc-1004 | cc-1005
region: us | eu | global
pci-scope: true | false (opcional, solo para payments)
```

**Justificación:**
- **environment:** Diferenciar costos por ambiente
- **team:** Chargeback por línea de negocio
- **cost-center:** Integración con sistema financiero
- **region:** Tracking de multi-region deployments
- **pci-scope:** Identificación rápida de recursos en scope

**Enforcement:**
- Organization policy que requiere estos labels
- Validación en Terraform modules
- Alertas si recursos se crean sin labels

### 5. Billing Accounts

**Estructura:**
```
Billing Account: DataMartX Master
├── Subaccount: Production
│   └── Todos los proyectos de producción
├── Subaccount: Staging
│   └── Todos los proyectos de staging
├── Subaccount: Development
│   └── Proyecto shared-dev
└── Subaccount: Shared Services
    └── Proyectos de networking, security, logging
```

**Justificación:**
- Separación por ambiente para budgets diferentes
- Shared services separado para costos de plataforma
- Facilita chargeback y showback

**Budgets:**
- Production: $100K/month (alertas: 50%, 80%, 100%)
- Staging: $20K/month (alertas: 50%, 80%, 100%)
- Development: $10K/month (alertas: 50%, 80%, 100%)
- Payments-prod: $30K/month (alertas: 40%, 70%, 90% - más agresivas)

### 6. Organization Policies Críticas

**1. Restricción de regiones:**
```yaml
constraint: constraints/gcp.resourceLocations
policy: allow only us-central1, us-east1, europe-west1
scope: Organization-wide
```
**Justificación:** GDPR requiere datos de EU en EU. Control de soberanía de datos.

**2. Labels obligatorios:**
```yaml
constraint: constraints/iam.tagKeys
policy: require environment, team, cost-center
scope: Organization-wide
```
**Justificación:** Sin labels, imposible hacer chargeback.

**3. Service account keys:**
```yaml
constraint: constraints/iam.disableServiceAccountKeyCreation
policy: enforced = true
scope: Organization-wide
```
**Justificación:** Prevenir exposición de credenciales. Usar Workload Identity.

**4. Storage uniform access:**
```yaml
constraint: constraints/storage.uniformBucketLevelAccess
policy: enforced = true
scope: Organization-wide
```
**Justificación:** Prevenir ACLs inconsistentes. Simplificar IAM.

**5. Disable public access:**
```yaml
constraint: constraints/storage.publicAccessPrevention
policy: enforced = true
scope: Organization-wide
```
**Justificación:** Prevenir data leaks por buckets públicos accidentally.

## Tabla de Proyectos

| Project ID | Name | Folder | Labels | APIs | Budget |
|------------|------|--------|--------|------|--------|
| marketplace-prod-us | Marketplace Production US | Production/Marketplace | env=prod, team=marketplace, region=us, cc=1001 | compute, sql, gcs, bq | $40K/mo |
| marketplace-prod-eu | Marketplace Production EU | Production/Marketplace | env=prod, team=marketplace, region=eu, cc=1001 | compute, sql, gcs, bq | $20K/mo |
| logistics-prod | Logistics Production | Production/Logistics | env=prod, team=logistics, region=us, cc=1002 | compute, sql, gcs, dataflow | $15K/mo |
| payments-prod | Payments Production | Production/Payments | env=prod, team=payments, pci=true, cc=1003 | compute, sql, kms | $30K/mo |
| analytics-prod | Analytics Production | Production/Analytics | env=prod, team=analytics, region=us, cc=1004 | bigquery, dataflow, composer | $25K/mo |
| corporate-prod | Corporate Production | Production/Corporate | env=prod, team=corporate, region=us, cc=1005 | compute, workspace | $10K/mo |
| marketplace-staging | Marketplace Staging | Staging | env=staging, team=marketplace, cc=1001 | compute, sql, gcs | $5K/mo |
| logistics-staging | Logistics Staging | Staging | env=staging, team=logistics, cc=1002 | compute, sql, gcs | $3K/mo |
| payments-staging | Payments Staging | Staging | env=staging, team=payments, cc=1003 | compute, sql, kms | $5K/mo |
| analytics-staging | Analytics Staging | Staging | env=staging, team=analytics, cc=1004 | bigquery, dataflow | $4K/mo |
| corporate-staging | Corporate Staging | Staging | env=staging, team=corporate, cc=1005 | compute, workspace | $3K/mo |
| shared-dev | Shared Development | Development | env=dev, team=shared, cc=9999 | compute, sql, gcs | $10K/mo |
| networking-shared | Networking Shared | Shared Services | env=prod, team=platform, cc=9000 | compute, dns | $5K/mo |
| security-shared | Security Shared | Shared Services | env=prod, team=security, cc=9001 | kms, secretmanager | $3K/mo |
| logging-shared | Logging Shared | Shared Services | env=prod, team=platform, cc=9000 | logging, monitoring | $2K/mo |

**Total projects:** 15  
**Total monthly budget:** ~$180K (de los $2M anuales)

## Escalabilidad

### Crecimiento a 3 años (200 proyectos)

**Estrategia:**
1. **Agregar regiones:** marketplace-prod-ap, logistics-prod-eu
2. **Nuevas líneas de negocio:** Folder: NewBusiness → proyectos
3. **Adquisiciones:** Folder: AcquiredCompany → migración gradual
4. **Microservicios:** marketplace-prod-us-api, marketplace-prod-us-worker

**Capacidad de la estructura:**
- Folders: Soporta hasta 4 niveles (actualmente 3)
- Projects: Sin límite práctico (GCP soporta miles)
- Labels: Hasta 64 labels por recurso (usamos 5)

**Mantenimiento:**
- Terraform modules reutilizables
- Automation para creación de proyectos
- Self-service con gobernanza (Service Catalog)

## Seguridad

### Aislamiento de PCI Scope

**Payments-prod:**
- Folder separado con organization policies específicas
- VPC aislado (no compartido)
- KMS dedicado para encryption keys
- Audit logs en proyecto separado
- Acceso restringido a grupo `payments-ops@datamartx.com`

**Enforcement:**
```yaml
# Organization policy solo para payments folder
constraint: constraints/compute.vmExternalIpAccess
policy: deny all (no public IPs)

constraint: constraints/sql.restrictPublicIp
policy: enforced = true (no public DB access)
```

### Separación de Duties

**Grupos de Google Workspace:**
```
gcp-super-admins@datamartx.com     → Organization Admin (3 personas)
gcp-billing-admins@datamartx.com   → Billing Admin (2 personas)
gcp-security-admins@datamartx.com  → Security Admin (3 personas)

marketplace-devs@datamartx.com     → Developer en marketplace-*
marketplace-ops@datamartx.com      → Editor en marketplace-prod-*
marketplace-viewers@datamartx.com  → Viewer en marketplace-*

payments-devs@datamartx.com        → Developer en payments-staging
payments-ops@datamartx.com         → Editor en payments-prod (5 personas, MFA required)
```

**Principio de mínimo privilegio:**
- Devs no tienen acceso a producción
- Ops tienen acceso a producción pero no pueden cambiar IAM
- Security tiene acceso de lectura a todo, write solo en security-shared

## Próximos Pasos

1. **Día 2:** Implementar IAM policies detalladas
2. **Día 3:** Configurar Shared VPC para networking
3. **Día 4:** Setup de audit logging centralizado
4. **Día 5:** Implementar organization policies con Terraform
5. **Día 6:** Configurar budgets y alerts
6. **Día 7:** Documentar runbooks para operaciones

## Conclusión

Esta arquitectura:
- ✅ Soporta los requisitos actuales de DataMartX
- ✅ Escala a 200 proyectos en 3 años
- ✅ Cumple con PCI DSS y GDPR
- ✅ Permite chargeback por línea de negocio
- ✅ Mantiene gobernanza centralizada con autonomía por equipo
- ✅ Es manejable por un equipo de 5 platform engineers

**Trade-off aceptado:** Mayor complejidad inicial (15 proyectos vs 5) por escalabilidad y compliance a largo plazo.
