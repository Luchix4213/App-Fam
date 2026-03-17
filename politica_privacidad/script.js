// Mostrar año automático en el footer

const year = new Date().getFullYear()

const footer = document.querySelector("footer p")

footer.innerHTML = `© ${year} Federación de Asociaciones Municipales de Bolivia`