# GCP Cloud Data Platforms Master Course

> De Data Engineer a Cloud Architect: 180 días de entrenamiento intensivo con práctica diaria, code reviews profesionales y preparación para doble certificación.

## Overview

Este no es un curso más de GCP. Es un programa de entrenamiento diseñado como el onboarding de un Cloud Architect en Google, con la misma intensidad y rigor que esperarías en una empresa FAANG.

**Duración:** 180 días  
**Certificaciones:** Professional Cloud Architect + Professional Data Engineer  
**Formato:** Teoría + Ejercicios prácticos + Code reviews  
**Industrias:** E-commerce, Fintech, Gaming/Streaming, Healthcare

## ¿Qué vas a aprender?

- **Diseño de arquitectura cloud** a escala empresarial
- **Implementación con Terraform** (Infrastructure as Code)
- **Data engineering** con BigQuery, Dataflow, Pub/Sub, Composer
- **Streaming y real-time** con arquitecturas event-driven
- **Kubernetes** con GKE y ecosistema Cloud Native
- **Machine Learning** con Vertex AI
- **Seguridad y compliance** (HIPAA, PCI DSS, SOC 2)
- **Optimización de costos** y FinOps
- **Observabilidad** y operaciones de producción

## Estructura del Curso

| Fase | Días | Industria | Enfoque |
|------|------|-----------|---------|
| 1 | 1-45 | E-commerce (DataMartX) | Fundamentos + Migración + Data Engineering |
| 2 | 46-90 | Fintech | Streaming + Seguridad + Observabilidad |
| 3 | 91-135 | Gaming/Streaming | Kubernetes + ML + Arquitectura avanzada |
| 4 | 136-165 | Healthcare | Compliance + Zero Trust + Edge |
| 5 | 166-180 | Multi-industria | Certification prep intensivo |

## Estructura de Cada Día

Cada día incluye:

1. **Lección teórica** (`lessons/dayXXX.md`) - Conceptos profundos, trade-offs, errores comunes
2. **Ejercicios** (`exercises/dayXXX.md`) - 1 diseño arquitectónico + 2 implementaciones
3. **Soluciones** (`solutions/dayXXX/`) - Código Terraform + documentación

## Requisitos Previos

- Conocimientos de SQL (nivel intermedio-avanzado)
- Python (pandas, airflow, dagster)
- Conceptos básicos de cloud computing
- Cuenta de Google Cloud con billing habilitado
- gcloud CLI y Terraform instalados

## Setup

```bash
# 1. Autenticarse en GCP
gcloud auth login
gcloud auth application-default login

# 2. Configurar proyecto
gcloud config set project [PROJECT_ID]

# 3. Habilitar APIs necesarias
./setup/gcp_setup.sh

# 4. Configurar Terraform
terraform init
```

## Metodología

### Aprender haciendo
No verás diapositivas aburridas. Cada día resolverás problemas reales de negocio:
- Tickets estilo Jira con contexto de industria
- Decisiones de arquitectura con trade-offs reales
- Implementaciones con Terraform de producción

### Code reviews profesionales
Cada solución será evaluada como lo haría un Principal Engineer:
- Legibilidad y organización
- Seguridad by design
- Optimización de costos
- Escalabilidad
- Mejores prácticas

### Construcción de portafolio
Al final del curso tendrás:
- 180 días de lecciones documentadas
- Múltiples proyectos Terraform
- Diagramas de arquitectura
- Decisiones de diseño justificadas

## Certificaciones

### Professional Cloud Architect
Cubre los 6 dominios del examen:
1. Designing and planning cloud solution architecture
2. Managing and provisioning solution infrastructure
3. Designing for security and compliance
4. Analyzing and optimizing technical and business processes
5. Assuring solution and operations reliability
6. Managing implementation process

### Professional Data Engineer
Cubre los 5 dominios del examen:
1. Designing and processing data
2. Building and operationalizing data processing systems
3. Storing and managing data
4. Ensuring data quality
5. Preparing and serving ML models

## Progreso

- [x] Setup del proyecto
- [ ] Día 1: GCP Architecture, Projects, Organizations
- [ ] ...

## Recursos

- [GCP Documentation](https://cloud.google.com/docs)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud Architect Exam Guide](https://cloud.google.com/learn/certification/cloud-architect)
- [Data Engineer Exam Guide](https://cloud.google.com/learn/certification/data-engineer)

## Licencia

Este es un proyecto educativo personal. Los escenarios de negocio son ficticios.
