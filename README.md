# Larpsec 2.8 para Matcha

Selector cosmético local para Murder Duels. El panel negro aparece al ejecutar; **Right Shift** lo abre y lo oculta. Elige una skin y cambia de arma normalmente para que el juego reconstruya el modelo.

## Ejecutar

El archivo público `Larpsec.lua` es el script principal. El loader fijo es:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/onlycodeme/Larpsec/main/Larpsec.lua"))()
```

Las futuras actualizaciones se publican reemplazando `Larpsec.lua`; la llamada del loader no cambia. El panel aparece al cargar cuando Roblox tiene el foco. **Right Shift** lo alterna; si queda oculto, abre la pestaña nativa **Larpsec** de Matcha y pulsa **Open skin panel**. Si se ejecuta desde otra ventana, vuelve a Roblox para ver el dibujo.

## Activación

| Función | Requisito |
|---|---|
| Panel, IDs de hasta 15 caracteres, perfil y Auto Apply | Drawing, UI Binding y archivos de Matcha; sin Hybrid ni Unsafe. |
| IDs largos | **Allow Unsafe LuaU** en Matcha y **Extended skins = ON** en Larpsec. Si no se valida la disposición de memoria, esas skins no aparecen. |
| Iconos nativos del hotbar | **Allow Unsafe LuaU** y `Native hotbar icons = ON`. Es una escritura local validada al campo de imagen de `WeaponIcon`; no usa Hybrid ni envía remotos. Solo se muestran skins con ID de imagen Roblox validado. |

Larpsec no llama FireServer ni InvokeServer. Hybrid no es necesario para las funciones implementadas; durante las pruebas ya estaba activado y no se cambió esa preferencia.

## IDs largos

El fallo de 15 caracteres se encontró en las escrituras de cadenas de esta instalación de Matcha. No es un límite de los IDs del juego. El modo extendido asigna temporalmente un nombre corto a la plantilla original y a los paquetes asociados de sonido, animación y equipamiento que encuentra. El juego continúa construyendo el arma con sus piezas y uniones. El perfil conserva el ID verdadero.

Las plantillas permanecen en sus carpetas y no se modifica su geometría. Las direcciones se vuelven a validar en cada ejecución. Los nombres se restauran al elegir otra skin o descargar Larpsec.

**Este modo es experimental y escribe memoria. Una actualización de Roblox o cerrar la VM a la fuerza puede dejar cambios locales o provocar un cierre. Ejecuta `Larpsec.Unload()` antes de desactivar Unsafe LuaU.** Si falla la restauración, habilita Unsafe de nuevo y llama a Unload; si no se recupera, reinicia Roblox.

Si otro jugador usa la misma plantilla original, Larpsec rechaza o suspende el cambio extendido para evitar alterar su apariencia local. Puedes reintentar seleccionando la skin más tarde.

## Guardado

El perfil conserva las dos skins, favoritos, Auto Apply y preferencias. Auto Apply apagado conserva el loadout sin aplicarlo al siguiente inicio. Elegir una skin manualmente sigue funcionando durante la sesión. Restaurar originales conserva la selección guardada. Cada guardado verifica la escritura y mantiene una copia anterior válida.

## Comprobado y pendiente

- Guardado, recarga con Auto Apply activado y apagado, recarga de un ID largo y limpieza de los dibujos registrados: comprobados.
- **Versión local 2.8:** compiló con `loadstring` de Matcha y se ejecutó en Practice sin iniciar duelo. La GUI abrió, el perfil cargó, los iconos del hotbar coincidieron con Seraphim y Murder Note, no aparecieron duplicados flotantes y Right Shift abrió el panel con una pulsación sostenida corta.
- Omega Energy Blade, Green Energy Blade y Omega Energy Blaster: reconstrucción nativa comprobada; sus cantidades de MeshPart coinciden con las plantillas. Blue Energy Blaster fue rechazada correctamente por conflicto con otro jugador. Las demás skins largas no están certificadas individualmente.
- **Iconos del hotbar:** Larpsec escribe el URI Roblox directamente al campo de cadena que usa cada `WeaponIcon`, con validación de dirección, capacidad, lectura posterior y rollback. El catálogo tiene 207 modelos: 158 poseen IDs nativos y las 49 entradas sin ID se ocultan. La escritura es local y no cambia el inventario del servidor. La versión 2.8 vuelve a aplicar el icono antes de cada render y vuelve a buscar las ranuras cada 50 ms durante la ronda y cada 100 ms en el lobby. La prueba visual en Practice confirmó los dos iconos seleccionados y que no salen duplicados flotantes. Quité por completo el overlay externo. Matcha no expone un evento de cambio ni prioridad de render para interceptar todas las reconstrucciones antes del juego, así que no puedo prometer cero destellos; tampoco he vuelto a probar el cambio de ventajas.
- **Repeticiones:** el controlador del juego recibe `ReplayData` y reconstruye cada actor desde los datos de participantes, incluidos los IDs de arma. Larpsec solo cambia atributos locales y no envía ni modifica ese paquete, así que su skin local no se replica a otros espectadores. La invisibilidad que persistió tras descargar Larpsec no demuestra que todos la vean; para confirmar si es un fallo compartido hace falta comparar la misma repetición desde otro cliente. La versión 2.7 pausa los cambios al detectar antes el marcador `LobbySpectateMatchId` y reanuda al salir. Esto mejora la transición, pero no afirma corregir la visibilidad del arma dentro de la repetición.
- Los paquetes de sonido y animación se conservan y se resuelven mediante el nombre corto cuando están disponibles. No se ha probado cada disparo, estela, animación o sonido de cada skin. No se promete equivalencia completa.

No se inició ningún duelo. Una prueba descartada de mover una copia dejó una referencia vacía en el personaje de práctica; el personaje se regeneró y esa técnica no forma parte del producto.

## MCP para continuar el desarrollo

Con Roblox y Matcha abiertos y el bridge habilitado, su dirección es `http://127.0.0.1:8765/mcp`. Para registrarlo desde una terminal con Codex CLI instalado:

```text
codex mcp add matcha --url http://127.0.0.1:8765/mcp
```

El MCP sirve para investigar durante el desarrollo. No hace falta para ejecutar el loader.

Referencias: [memoria y riesgos](https://huoadf.github.io/matcha-docs/memory/), [API e Hybrid](https://huoadf.github.io/matcha-docs/classes/), [require y ejecución protegida](https://huoadf.github.io/matcha-docs/functions-misc/). Las pruebas de la instalación tienen prioridad cuando las referencias difieren.

