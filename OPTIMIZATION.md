# Reporte Final de Optimización y Plan de Implementación - Ambxst

Este documento detalla el análisis del rendimiento y el plan de ejecución para optimizar Ambxst, enfocado en minimizar el uso de recursos (CPU/RAM) y maximizar la fluidez.

## 1. Análisis de Cuellos de Botella

### 1.1. Monitorización del Sistema (Crítico)
El archivo `modules/services/SystemResources.qml` es la principal fuente de overhead en segundo plano.
- **Estado Actual:** Spawnea ~5-7 procesos independientes (`cat`, `sh`, `nvidia-smi`, `df`) cada 2 segundos.
- **Impacto:** Alto consumo de CPU por `fork/exec` repetitivo y cambios de contexto. Lag spikes potenciales por comandos lentos (`nvidia-smi`).
- **Solución:** Unificar en un solo proceso persistente (Python Daemon).

### 1.2. Gestión de Workspaces (Alto)
El componente `modules/bar/workspaces/Workspaces.qml` realiza cálculos pesados en el hilo UI.
- **Estado Actual:** Recalcula ocupación y rangos visuales ante *cualquier* señal de Hyprland (movimiento de ventana, foco, etc.). Busca iconos en disco síncronamente.
- **Impacto:** Micro-tartamudeos (stutter) durante el uso intensivo del gestor de ventanas.
- **Solución:** Debounce de señales y caché de iconos.

### 1.3. Búsqueda de Aplicaciones (Medio)
`modules/services/AppSearch.qml` realiza búsquedas lineales ineficientes.
- **Estado Actual:** Itera toda la lista de apps y normaliza strings (`toLowerCase`) en cada pulsación de tecla.
- **Impacto:** Latencia en el lanzador con muchas apps instaladas.
- **Solución:** Indexado al inicio.

## 2. Estado de la Implementación (Completada)

### Paso 1: Unificación de SystemResources (Python Daemon)
- **Hecho:** Se creó `scripts/system_monitor.py`.
    - Loop eficiente con `time.sleep(2)`.
    - Lectura directa de `/proc` y `os.statvfs`.
    - Detección de GPU optimizada (Nvidia/AMD/Intel).
- **Hecho:** Se refactorizó `modules/services/SystemResources.qml`.
    - Eliminados procesos redundantes (`Process`).
    - Integrado `monitorProcess` único que consume el JSON del script.

### Paso 2: Optimización de Workspaces
- **Hecho:** Se modificó `modules/bar/workspaces/Workspaces.qml`.
    - Añadido `Timer` de 50ms para debouncing de actualizaciones.
    - Reemplazadas llamadas directas por reinicio del temporizador.
    - Implementado uso de `AppSearch.getCachedIcon`.

### Paso 3: Optimización de AppSearch
- **Hecho:** Se modificó `modules/services/AppSearch.qml`.
    - Implementado `searchIndex` generado al inicio (`buildIndex`).
    - Añadida caché de iconos (`iconCache` y `getCachedIcon`).
    - `fuzzyQuery` ahora utiliza el índice pre-calculado.

### Paso 4: Ajustes Menores
- **Hecho:** Se modificó `modules/services/TaskbarApps.qml`.
    - Aumentado debounce de 50ms a 100ms.

## 3. Verificación
El sistema ahora debería mostrar:
1.  Menor uso de CPU en reposo (gracias al monitor unificado).
2.  Animaciones de workspace más fluidas (menos bloqueo del hilo UI).
3.  Búsqueda de aplicaciones más rápida y con menos lag al escribir.
4.  Menos escrituras/lecturas de disco redundantes.

## 4. Próximos Pasos (Opcional)
- Considerar optimización de `WeatherService` si se detectan bloqueos (actualmente es un proceso `sh` cada 10 min, bajo impacto).
- Revisar shaders de fondo si el uso de GPU en idle sigue siendo alto.
