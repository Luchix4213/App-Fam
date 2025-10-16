# 🔧 Diagnóstico del Error "Error al obtener asociaciones"

## 🚨 Problema Identificado

El error "Error al obtener asociaciones" puede tener varias causas. He identificado y corregido algunos problemas potenciales:

## ✅ Correcciones Realizadas

### 1. **Nombres de Campos Incorrectos**
- **Problema**: Usaba `departamentoId` pero la relación está definida como `id_departamento`
- **Solución**: Corregido en `asociacion.controller.js` y `miembro.controller.js`

### 2. **Logs de Debug Agregados**
- Agregué logs para ver qué está pasando en el backend
- Ahora verás en la consola del servidor información útil

## 🔍 Pasos para Diagnosticar

### Paso 1: Verificar el Backend
```bash
cd backend_fam
npm start
```

### Paso 2: Verificar Datos en la Base de Datos
```bash
cd backend_fam
node src/test/checkData.js
```

Este script verificará:
- Si hay departamentos en la base de datos
- Si hay asociaciones
- Si las relaciones están funcionando correctamente

### Paso 3: Probar con Postman

#### Obtener Departamentos:
```
GET http://localhost:4000/api/departamentos/public
Authorization: Bearer <tu_token>
```

#### Obtener Asociaciones por Departamento:
```
GET http://localhost:4000/api/asociaciones/departamento/1
Authorization: Bearer <tu_token>
```

### Paso 4: Verificar Logs del Backend
Cuando hagas la petición desde la app, deberías ver en la consola del backend:
```
Buscando asociaciones para departamento: 1
Rol del usuario: usuario
Asociaciones encontradas: X
```

## 🛠️ Posibles Causas del Error

### 1. **Base de Datos Vacía**
- No hay datos en las tablas `departamento`, `asociaciones` o `miembros`

### 2. **Problemas de Conexión**
- El backend no está ejecutándose
- Puerto incorrecto (debería ser 4000)

### 3. **Token de Autenticación**
- Token expirado o inválido
- Usuario no autenticado

### 4. **Estructura de Base de Datos**
- Las tablas no existen
- Las relaciones no están configuradas correctamente

## 🚀 Soluciones Rápidas

### Si la base de datos está vacía:
```sql
-- Insertar un departamento de prueba
INSERT INTO departamento (nombre) VALUES ('La Paz');

-- Insertar una asociación de prueba
INSERT INTO asociaciones (nombre, alias, municipio, id_departamento, estado) 
VALUES ('Asociación de Municipios de La Paz', 'AMLAP', 'La Paz', 1, 'activo');
```

### Si hay problemas de conexión:
1. Verifica que el backend esté ejecutándose en puerto 4000
2. Verifica que la URL en `api_service.dart` sea correcta:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:4000/api';
   ```

### Si el token está expirado:
1. Haz logout y vuelve a hacer login
2. Verifica que el token se esté enviando correctamente

## 📋 Checklist de Verificación

- [ ] Backend ejecutándose en puerto 4000
- [ ] Base de datos MySQL conectada
- [ ] Usuario autenticado (token válido)
- [ ] Datos en las tablas departamento y asociaciones
- [ ] Relaciones configuradas correctamente
- [ ] URL correcta en la app Flutter

## 🔧 Comandos Útiles

### Verificar estado del backend:
```bash
curl http://localhost:4000/api/departamentos/public \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

### Reiniciar el backend:
```bash
cd backend_fam
npm start
```

### Ver logs en tiempo real:
```bash
cd backend_fam
npm start | grep "Buscando asociaciones"
```

¡Ejecuta estos pasos y dime qué encuentras! 🕵️‍♂️
