# 🍲 La Ruta del Sabor

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Android%20Studio-IDE-3DDC84?logo=androidstudio&logoColor=white" alt="Android Studio">
  <img src="https://img.shields.io/badge/VS%20Code-Development-007ACC?logo=visualstudiocode&logoColor=white" alt="VS Code">
  <img src="https://img.shields.io/badge/Git-Version%20Control-F05032?logo=git&logoColor=white" alt="Git">
  <img src="https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white" alt="GitHub">
</p>

<p align="center">
  <strong>📍 Descubre Cochabamba a través de sus sabores tradicionales</strong>
</p>

---

## 📱 Sobre el proyecto

**La Ruta del Sabor** es una aplicación móvil desarrollada con **Flutter y Dart**, orientada a la promoción, descubrimiento y geolocalización de la gastronomía tradicional y las ferias culinarias itinerantes del municipio de **Cochabamba, Bolivia**.

El proyecto busca acercar a ciudadanos y visitantes a los diferentes lugares donde pueden encontrar platos tradicionales, pequeños comedores, caseras y ferias gastronómicas.

La aplicación pretende convertirse en una herramienta digital que permita **descubrir, explorar y conocer la riqueza gastronómica cochabambina desde un dispositivo móvil**.

---

## 🎯 Objetivo del proyecto

Desarrollar una aplicación móvil que permita **visibilizar y facilitar el descubrimiento de la oferta gastronómica tradicional de Cochabamba**, proporcionando información organizada y accesible sobre platos, lugares gastronómicos y ferias culinarias.

### Objetivos específicos

* 🍽️ Promover la gastronomía tradicional cochabambina.
* 📍 Facilitar el descubrimiento de lugares gastronómicos.
* 🗺️ Mostrar información relacionada con ubicaciones y ferias.
* 🔎 Permitir explorar diferentes alternativas gastronómicas.
* 📱 Proporcionar una interfaz móvil sencilla y atractiva.
* 🌄 Contribuir a la difusión de la cultura gastronómica de Cochabamba.

---

# 🍛 Gastronomía de Cochabamba

La aplicación está orientada principalmente a la difusión de platos representativos de la gastronomía cochabambina y boliviana.

Entre los principales ejemplos se encuentran:

| 🍽️ Plato           | 📌 Descripción                                                                     |
| ------------------- | ---------------------------------------------------------------------------------- |
| 🥩 **Chicharrón**   | Uno de los platos tradicionales más representativos de Cochabamba.                 |
| 🍳 **Silpancho**    | Plato tradicional preparado con carne, arroz, papa, huevo y otros acompañamientos. |
| 🌶️ **Pique Macho** | Preparación popular a base de carne, papas y diferentes ingredientes.              |
| 🥜 **Sopa de Maní** | Sopa tradicional boliviana preparada con maní y diferentes ingredientes.           |

> 🇧🇴 **La Ruta del Sabor busca convertir la gastronomía en una experiencia digital accesible para todos.**

---

# ✨ Funcionalidades principales

La aplicación se encuentra en proceso de desarrollo y contempla funcionalidades como:

### 🏠 Inicio

Pantalla principal desde donde el usuario podrá acceder a las diferentes funcionalidades de la aplicación.

### 🔎 Exploración gastronómica

Permite consultar diferentes opciones gastronómicas disponibles.

### 🍲 Platos tradicionales

Presentación de información relacionada con platos tradicionales.

### 📍 Ubicaciones

Visualización de lugares gastronómicos y puntos de interés.

### 🎪 Ferias gastronómicas

Información sobre ferias culinarias itinerantes y actividades gastronómicas.

### 🗺️ Descubrimiento

Facilitar al usuario la búsqueda de alternativas gastronómicas dentro del municipio de Cochabamba.

---

# 🛠️ Tecnologías utilizadas

## Flutter

**Flutter** es el framework principal utilizado para desarrollar la aplicación móvil.

Se utilizará para:

* Construcción de las interfaces.
* Desarrollo de las diferentes pantallas.
* Creación de componentes reutilizables.
* Gestión de navegación.
* Adaptación de la aplicación a diferentes tamaños de pantalla.

Flutter permite desarrollar la aplicación utilizando una misma base de código y mantener una interfaz moderna y consistente.

---

## Dart

**Dart** es el lenguaje de programación utilizado por Flutter.

Será utilizado para:

* Implementar la lógica de la aplicación.
* Crear clases y modelos.
* Gestionar estados.
* Implementar navegación.
* Procesar información.
* Construir los componentes de la aplicación.

El archivo principal de ejecución será:

```text
lib/main.dart
```

---

## 💻 Visual Studio Code

**Visual Studio Code** será utilizado como uno de los principales entornos para el desarrollo y edición del código fuente.

Se utilizará principalmente para:

* Escribir código Dart.
* Organizar la estructura del proyecto.
* Instalar y utilizar extensiones de Flutter.
* Ejecutar comandos desde la terminal.
* Revisar y modificar los archivos del proyecto.
* Gestionar el código mediante Git.

---

## 🤖 Android Studio

**Android Studio** será utilizado principalmente como herramienta complementaria para el desarrollo y prueba de la aplicación Android.

Permitirá trabajar con:

* Android SDK.
* Emuladores Android.
* Dispositivos virtuales.
* Herramientas de compilación.
* Ejecución y pruebas de la aplicación.

De esta manera, **Visual Studio Code y Android Studio se complementan** dentro del proceso de desarrollo.

> 💡 VS Code se utilizará principalmente para la programación, mientras que Android Studio permitirá disponer del entorno Android necesario para ejecutar y probar la aplicación.

---

## 🔀 Git y GitHub

**Git** será utilizado para el control de versiones del proyecto.

**GitHub** será utilizado como plataforma para almacenar y gestionar el código fuente de manera colaborativa.

Esto permitirá:

* Mantener un historial de cambios.
* Trabajar mediante ramas.
* Registrar avances.
* Recuperar versiones anteriores.
* Integrar cambios realizados por diferentes integrantes.
* Mantener organizado el desarrollo del proyecto.

---

# 🏗️ Arquitectura del proyecto

El proyecto utilizará una estructura organizada por responsabilidades, buscando mantener el código limpio, escalable y fácil de mantener.

```text
lib/
│
├── core/
│   ├── routes/
│   │   └── # Manejo de rutas y navegación global
│   │
│   └── theme/
│       └── # Configuración del tema visual
│
├── presentation/
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── explorer_screen.dart
│   │
│   └── widgets/
│       └── # Componentes visuales reutilizables
│
└── main.dart
    # Punto de entrada de la aplicación
```

---

# 📂 Estructura de carpetas

### `core/`

Contendrá elementos generales utilizados por diferentes partes de la aplicación.

### `core/routes/`

Contendrá la configuración relacionada con las rutas y navegación entre pantallas.

### `core/theme/`

Contendrá la configuración visual global de la aplicación, como:

* Colores.
* Tipografías.
* Estilos.
* Tema general.
* Elementos visuales.

### `presentation/`

Contendrá principalmente los elementos relacionados con la presentación e interfaz de usuario.

### `presentation/screens/`

Aquí se encontrarán las diferentes pantallas de la aplicación.

Ejemplo:

```text
HomeScreen
ExplorerScreen
```

### `presentation/widgets/`

Contendrá componentes reutilizables de la interfaz.

Por ejemplo:

```text
FoodCard
RestaurantCard
CategoryCard
SearchBar
```

### `main.dart`

Es el punto de entrada de la aplicación Flutter.

Desde este archivo se inicializará la aplicación y se configurarán los elementos principales.

---

# 🚀 Instalación y ejecución

## 1. Clonar el repositorio

Desde una terminal:

```bash
git clone https://github.com/TU-USUARIO/la-ruta-del-sabor.git
```

Ingresar al proyecto:

```bash
cd la-ruta-del-sabor
```

---

## 2. Verificar Flutter

Ejecutar:

```bash
flutter doctor
```

Este comando permitirá comprobar que Flutter y las herramientas necesarias estén correctamente configuradas.

---

## 3. Instalar dependencias

Ejecutar:

```bash
flutter pub get
```

---

## 4. Ejecutar la aplicación

Con un dispositivo Android o emulador disponible:

```bash
flutter run
```

También puede ejecutarse desde Visual Studio Code o Android Studio seleccionando el dispositivo correspondiente.

---

# 📱 Ejecución en Android

Para probar la aplicación en Android se podrá utilizar:

### Opción 1 — Dispositivo físico

Conectar un teléfono Android mediante USB y habilitar la depuración USB.

Después ejecutar:

```bash
flutter devices
```

Y posteriormente:

```bash
flutter run
```

### Opción 2 — Emulador

Desde Android Studio se podrá iniciar un dispositivo virtual Android y posteriormente ejecutar:

```bash
flutter run
```

---

# 🔄 Flujo de trabajo con Git y GitHub

Para mantener organizado el desarrollo del equipo se recomienda trabajar mediante ramas.

### Crear una rama

```bash
git checkout -b feature/nombre-funcionalidad
```

Ejemplo:

```bash
git checkout -b feature/pantalla-explorador
```

### Revisar cambios

```bash
git status
```

### Agregar cambios

```bash
git add .
```

### Crear commit

```bash
git commit -m "feat: agregar pantalla de exploración"
```

### Subir la rama

```bash
git push origin feature/pantalla-explorador
```

Posteriormente, los cambios podrán integrarse a la rama principal mediante un **Pull Request**.

---

# 🌿 Estrategia de ramas

Se propone utilizar la siguiente estructura:

```text
 main.dart
│   
├───core
│   ├───constants
│   │       app_colors.dart
│   │       supabase_constants.dart
│   │       
│   ├───routes
│   │       app_routes.dart
│   │       
│   └───theme
│           app_theme.dart
│           
├───data
│   ├───models
│   │       establecimiento_model.dart
│   │       home_data_model.dart
│   │       place_model.dart
│   │       plato_dia_item.dart
│   │       solicitud_model.dart
│   │       usuario_model.dart
│   │       
│   └───services
│           establecimiento_service.dart
│           favoritos_service.dart
│           session_service.dart
│           solicitudes_service.dart
│           usuarios_service.dart
│           
├───features
└───presentation
    ├───screens
    │   ├───admin
    │   │       admin_dashboard_screen.dart
    │   │       
    │   ├───auth
    │   │       login_screen.dart
    │   │       register_screen.dart
    │   │       welcome_screen.dart
    │   │       
    │   ├───comensal
    │   │       comensal_main_navigation_screen.dart
    │   │       home_screen.dart
    │   │       map_screen.dart
    │   │       plato_dia_screen.dart
    │   │       profile_screen.dart
    │   │       
    │   └───duenno
    │           duenno_home_screen.dart
    │           duenno_main_navigation_screen.dart
    │           duenno_profile_screen.dart
    │           requests_screen.dart
    │           
    └───widgets
            custom_navbar.dart
            shared_widgets.dart
```

### `main`

Contendrá versiones estables del proyecto.

### `develop`

Será utilizada para integrar los avances antes de incorporarlos a `main`.

### `feature/*`

Se utilizarán para desarrollar funcionalidades específicas.

Ejemplo:

```text
feature/home
feature/explorer
feature/ferias
```

---

# 📸 Evidencias del desarrollo

En esta sección se podrán incorporar posteriormente capturas de pantalla de las diferentes interfaces desarrolladas.

### 🏠 Pantalla de inicio

> Próximamente se incorporará la captura de la pantalla principal.

### 🔎 Pantalla de exploración

> Próximamente se incorporará la captura de exploración gastronómica.

### 🍲 Detalle gastronómico

> Próximamente se incorporará la interfaz correspondiente.

### 📍 Ubicaciones

> Próximamente se incorporará la interfaz de ubicación.

---

# 🎨 Experiencia visual

La interfaz de **La Ruta del Sabor** estará orientada a representar la identidad gastronómica y cultural de Cochabamba.

Se buscará una experiencia:

* 📱 Moderna.
* 🍲 Gastronómica.
* 🇧🇴 Representativa de Bolivia.
* 🧭 Fácil de navegar.
* 👨‍🍳 Cercana a los pequeños negocios y caseras.
* 🔎 Sencilla para descubrir nuevos lugares.

Los elementos visuales se irán definiendo durante el desarrollo de las diferentes pantallas.

---

# 📋 Estado del proyecto

| Área                       | Estado           |
| -------------------------- | ---------------- |
| 📱 Configuración Flutter   | 🟢 En desarrollo |
| 🎨 Diseño de interfaz      | 🟡 En desarrollo |
| 🏠 Pantalla principal      | 🟡 En desarrollo |
| 🔎 Explorador gastronómico | 🟡 En desarrollo |
| 🍲 Información de platos   | 🟡 En desarrollo |
| 📍 Ubicaciones             | 🟡 En desarrollo |
| 🎪 Ferias gastronómicas    | 🟡 Planificado   |
| 🧪 Pruebas Android         | 🟡 En desarrollo |
| 🚀 Versión final           | 🔴 Pendiente     |

---

# 👥 Equipo de desarrollo

**Proyecto Formativo — Entregable 2**

**Materia:** Desarrollo de Aplicaciones Móviles

**Ubicación:** Cochabamba, Bolivia 🇧🇴

**Gestión:** 2026

---

# 🎓 Contexto académico

Este proyecto forma parte del proceso formativo de la materia **Desarrollo de Aplicaciones Móviles**, teniendo como finalidad aplicar conocimientos relacionados con:

* Desarrollo de aplicaciones móviles.
* Programación con Dart.
* Framework Flutter.
* Diseño de interfaces.
* Navegación entre pantallas.
* Arquitectura y organización del código.
* Control de versiones con Git.
* Gestión colaborativa mediante GitHub.
* Pruebas en dispositivos Android.

---

# 🌎 Impacto esperado

**La Ruta del Sabor** busca contribuir a la difusión de la gastronomía cochabambina mediante una herramienta tecnológica accesible.

La propuesta pretende brindar mayor visibilidad a:

👩‍🍳 Caseras y pequeños emprendimientos
🍲 Comedores populares
🎪 Ferias gastronómicas
🥘 Platos tradicionales
📍 Lugares gastronómicos
🇧🇴 Cultura culinaria boliviana

La tecnología se convierte así en un medio para **conectar a las personas con los sabores y tradiciones de Cochabamba**.

---

# 🔮 Próximas funcionalidades

Entre las funcionalidades que podrán incorporarse durante las siguientes etapas se encuentran:

* [ ] 🔎 Búsqueda de lugares gastronómicos.
* [ ] 🍲 Catálogo de platos tradicionales.
* [ ] 📍 Información de ubicaciones.
* [ ] 🗺️ Integración de mapas.
* [ ] 🎪 Calendario de ferias gastronómicas.
* [ ] ⭐ Sistema de favoritos.
* [ ] 📸 Fotografías gastronómicas.
* [ ] 🔔 Notificaciones.
* [ ] 👤 Perfil de usuario.
* [ ] 📊 Información adicional de establecimientos.

---

# 🤝 Contribución

Si formas parte del equipo de desarrollo:

1. Clona el repositorio.
2. Crea una rama para tu funcionalidad.
3. Realiza los cambios.
4. Ejecuta las pruebas correspondientes.
5. Realiza un commit descriptivo.
6. Sube la rama a GitHub.
7. Crea un Pull Request.
8. Espera la revisión antes de integrar los cambios.

Ejemplo:

```bash
git checkout -b feature/nueva-funcionalidad

git add .

git commit -m "feat: agregar nueva funcionalidad"

git push origin feature/nueva-funcionalidad
```

---

# 📌 Convención de commits

Para mantener un historial organizado se recomienda utilizar mensajes descriptivos:

```text
feat: nueva funcionalidad
fix: corrección de error
style: cambios visuales
refactor: reorganización del código
docs: actualización de documentación
test: incorporación de pruebas
chore: configuración del proyecto
```

Ejemplos:

```text
feat: agregar pantalla de exploración
fix: corregir navegación entre pantallas
style: mejorar diseño de tarjetas gastronómicas
docs: actualizar README
```

---

# ❤️ La Ruta del Sabor

> ### “Descubre Cochabamba, un sabor a la vez.” 🍲🇧🇴

Una aplicación pensada para **descubrir, explorar y disfrutar la riqueza gastronómica de Cochabamba**.

---

<p align="center">
  <strong>🍲 La Ruta del Sabor</strong><br>
  Gastronomía • Cultura • Cochabamba • Tecnología
</p>

<p align="center">
  <sub>Proyecto Formativo — Desarrollo de Aplicaciones Móviles · 2026</sub>
</p>
