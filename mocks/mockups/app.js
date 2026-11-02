const descriptions = {
  welcome: ['Acceso', 'Presenta la misión social y permite iniciar el recorrido sin saturar al usuario.'],
  register: ['Registro', 'Primero define el rol porque este determina permisos, navegación y datos requeridos.'],
  'donor-home': ['Inicio del donante', 'Prioriza impacto, publicaciones recientes y la acción principal de donar.'],
  publish: ['Publicar donación', 'Agrupa los datos mínimos para que una organización decida y coordine responsablemente.'],
  'org-home': ['Inicio de organización', 'Facilita descubrir alimentos disponibles y comenzar una búsqueda.'],
  donations: ['Donaciones disponibles', 'Combina búsqueda, filtros y vencimiento para reducir el tiempo de exploración.'],
  detail: ['Detalle y reserva', 'Muestra condiciones, responsabilidad y datos de recojo antes de asumir el compromiso.'],
  history: ['Historial e impacto', 'Separa estados y muestra cantidades por unidad para evitar indicadores engañosos.'],
  profile: ['Perfil', 'Permite mantener datos de coordinación sin habilitar el cambio de rol.'],
};

const panels = [...document.querySelectorAll('[data-screen-panel]')];
const navButtons = [...document.querySelectorAll('[data-screen]')];
const title = document.querySelector('#review-title');
const description = document.querySelector('#review-description');
const modal = document.querySelector('.modal-backdrop');
const toast = document.querySelector('.toast');

function showScreen(name) {
  panels.forEach((panel) => panel.classList.toggle('active', panel.dataset.screenPanel === name));
  navButtons.forEach((button) => button.classList.toggle('active', button.dataset.screen === name));
  const content = descriptions[name];
  if (content) [title.textContent, description.textContent] = content;
}

navButtons.forEach((button) => button.addEventListener('click', () => showScreen(button.dataset.screen)));
document.querySelectorAll('[data-go]').forEach((button) => button.addEventListener('click', () => showScreen(button.dataset.go)));
document.querySelectorAll('.role-card').forEach((card) => card.addEventListener('click', () => {
  document.querySelectorAll('.role-card').forEach((item) => item.classList.remove('selected'));
  card.classList.add('selected');
}));

document.querySelector('[data-confirm]').addEventListener('click', () => { modal.hidden = false; });
document.querySelector('[data-close]').addEventListener('click', () => { modal.hidden = true; });
document.querySelector('[data-reserve]').addEventListener('click', () => {
  modal.hidden = true;
  showScreen('history');
  showToast('Reserva confirmada. Coordiná el recojo antes de la fecha límite.');
});

document.querySelectorAll('[data-toast]').forEach((button) => button.addEventListener('click', () => showToast(button.dataset.toast)));

function showToast(message) {
  toast.textContent = message;
  toast.hidden = false;
  window.setTimeout(() => { toast.hidden = true; }, 2600);
}
