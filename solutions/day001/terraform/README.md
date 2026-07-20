# Day 001 Solution - Terraform Implementation

## Overview

Esta solución implementa la estructura completa de organización de GCP para DataMartX usando Terraform con módulos reutilizables.

## Estructura

```
terraform/
├── modules/
│   ├── folder/          # Módulo para crear folders
│   ├── project/         # Módulo para crear proyectos
│   └── iam/             # Módulo para IAM bindings
├── main.tf              # Configuración principal
├── variables.tf         # Variables de entrada
├── outputs.tf           # Valores de salida
├── terraform.tf         # Provider y backend configuration
└── terraform.tfvars.example  # Ejemplo de variables
```

## Prerequisites

1. **Terraform** >= 1.0 instalado
2. **gcloud CLI** instalado y autenticado
3. **GCP Project** para Terraform state (o usar backend local)
4. **Permisos** necesarios:
   - Organization Admin o Super Admin
   - Billing Account Admin
   - Project Creator

## Setup

### 1. Configurar Backend (GCS)

Crear bucket para Terraform state:

```bash
# Crear proyecto para Terraform state
gcloud projects create terraform-state-datamartx \
  --name="Terraform State"

# Habilitar APIs
gcloud services enable storage.googleapis.com \
  --project=terraform-state-datamartx

# Crear bucket
gsutil mb -p terraform-state-datamartx \
  -l us-central1 \
  gs://datamartx-terraform-state

# Habilitar versioning
gsutil versioning set on gs://datamartx-terraform-state
```

### 2. Configurar Variables

Copiar el archivo de ejemplo:

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars`:

```hcl
organization_id    = "TU_ORGANIZATION_ID"
billing_account_id = "TU_BILLING_ACCOUNT_ID"
domain             = "datamartx.com"
```

### 3. Inicializar Terraform

```bash
terraform init
```

### 4. Planear la Ejecución

```bash
terraform plan -out=tfplan
```

Revisar el plan cuidadosamente. Deberías ver:
- 9 folders (1 shared services + 4 top-level + 4 production sub-folders)
- 15 proyectos
- Múltiples API activations

### 5. Aplicar la Configuración

```bash
terraform apply tfplan
```

### 6. Verificar Outputs

```bash
terraform output
```

Deberías ver todos los folder IDs y project IDs.

## Módulos

### Módulo: folder

Crea folders en la jerarquía de organización.

**Uso:**
```hcl
module "folder_example" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Example Folder"
  parent_folder_id = "123456789"  # optional
}
```

**Inputs:**
- `organization_id` (required): ID de la organización
- `folder_name` (required): Nombre del folder
- `parent_folder_id` (optional): ID del folder padre
- `labels` (optional): Labels para el folder

**Outputs:**
- `folder_id`: ID completo del folder (ej: "folders/123456789")
- `folder_name`: Nombre del folder

### Módulo: project

Crea proyectos con labels y APIs habilitadas.

**Uso:**
```hcl
module "project_example" {
  source = "./modules/project"

  project_id         = "example-project"
  project_name       = "Example Project"
  folder_id          = "folders/123456789"
  billing_account_id = "012345-6789AB-CDEF01"
  
  labels = {
    environment = "production"
    team        = "platform"
    cost-center = "cc-1001"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "storage.googleapis.com"
  ]
}
```

**Inputs:**
- `project_id` (required): ID único del proyecto
- `project_name` (required): Nombre display del proyecto
- `folder_id` (required): ID del folder donde crear el proyecto
- `billing_account_id` (required): ID de la cuenta de billing
- `labels` (required): Labels (debe incluir environment, team, cost-center)
- `apis_to_enable` (optional): Lista de APIs a habilitar
- `auto_create_network` (optional): Crear red por defecto (default: false)

**Outputs:**
- `project_id`: ID del proyecto
- `project_number`: Número del proyecto
- `project_name`: Nombre del proyecto

### Módulo: iam

Configura IAM bindings en proyectos.

**Uso:**
```hcl
module "iam_example" {
  source = "./modules/iam"

  project_id = "example-project"
  
  iam_bindings = {
    "roles/viewer" = [
      "group:viewers@datamartx.com"
    ]
    "roles/editor" = [
      "group:editors@datamartx.com"
    ]
  }
}
```

**Inputs:**
- `project_id` (required): ID del proyecto
- `iam_bindings` (optional): Map de role a lista de members
- `authoritative` (optional): Usar binding autoritativo (default: false)

**Outputs:**
- `bindings_applied`: Las bindings aplicadas

## Crear un Nuevo Proyecto

Para agregar un nuevo proyecto (ej: nueva línea de negocio):

### Opción 1: Agregar al main.tf

```hcl
module "project_new_business_prod" {
  source = "./modules/project"

  project_id         = "newbusiness-prod"
  project_name       = "New Business Production"
  folder_id          = module.folder_production.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "newbusiness"
    cost-center = "cc-1006"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "storage.googleapis.com"
  ]
}
```

### Opción 2: Crear archivo separado

Crear `projects/newbusiness.tf`:

```hcl
module "project_newbusiness_prod" {
  source = "./modules/project"
  
  # ... misma configuración
}
```

### Aplicar cambios

```bash
terraform plan
terraform apply
```

## Costos

**Costos de esta configuración:**
- Folders: Gratis
- Projects: Gratis
- APIs habilitadas: Gratis (solo pagas por uso)
- Terraform state en GCS: ~$0.01/month

**Presupuesto mensual estimado:**
- Production: $100K
- Staging: $20K
- Development: $10K
- Shared Services: $10K
- **Total: $140K/month** (sin contar workloads)

## Security Considerations

### Terraform State

El state de Terraform contiene información sensible (project IDs, folder IDs). Proteger:

1. **Backend remoto:** Usar GCS bucket con versioning
2. **Encryption:** GCS encripta por defecto
3. **Access control:** Solo platform admins tienen acceso al bucket
4. **No commit state:** Agregar `*.tfstate` a `.gitignore`

### Service Account para Terraform

Crear service account dedicado:

```bash
# Crear service account
gcloud iam service-accounts create terraform-runner \
  --display-name="Terraform Runner" \
  --project=terraform-state-datamartx

# Asignar roles necesarios
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member="serviceAccount:terraform-runner@terraform-state-datamartx.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.organizationAdmin"

gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member="serviceAccount:terraform-runner@terraform-state-datamartx.iam.gserviceaccount.com" \
  --role="roles/billing.admin"

# Descargar key (solo para CI/CD)
gcloud iam service-accounts keys create terraform-key.json \
  --iam-account=terraform-runner@terraform-state-datamartx.iam.gserviceaccount.com
```

## Troubleshooting

### Error: "The parent folder does not exist"

**Causa:** Estás creando un proyecto en un folder que no existe.

**Solución:** Verificar que el folder_id es correcto:
```bash
gcloud resource-manager folders list --organization=ORGANIZATION_ID
```

### Error: "Permission denied creating project"

**Causa:** Tu cuenta no tiene permisos de Project Creator.

**Solución:** Solicitar rol `roles/resourcemanager.projectCreator` en la organización.

### Error: "Billing account not found"

**Causa:** El billing account ID es incorrecto o no tienes acceso.

**Solución:** Verificar billing account:
```bash
gcloud billing accounts list
```

### Error: "API not enabled"

**Causa:** Estás usando un servicio que no está habilitado.

**Solución:** Habilitar la API:
```bash
gcloud services enable SERVICE_NAME.googleapis.com \
  --project=PROJECT_ID
```

## Next Steps

1. **Día 2:** Implementar IAM policies detalladas con el módulo `iam`
2. **Día 3:** Configurar Shared VPC para networking
3. **Día 4:** Setup de audit logging centralizado
4. **Día 5:** Implementar organization policies

## Resources

- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Resource Manager](https://cloud.google.com/resource-manager/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)
