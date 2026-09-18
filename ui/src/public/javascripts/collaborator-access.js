(() => {
  const list = document.querySelector('[data-access-list]');
  const template = document.querySelector('#collaborator-access-row-template');
  const addButton = document.querySelector('[data-add-access-row]');
  const status = document.querySelector('[data-access-status]');

  if (!list || !template || !addButton) return;

  const maximumRows = Number(list.dataset.maxRows) || 20;
  const rows = () => [...list.querySelectorAll('[data-access-row]')];
  let nextIndex = rows().reduce(
    (highest, row) => Math.max(highest, Number(row.dataset.rowIndex) || 0),
    0
  ) + 1;

  function updateRoleOptions(row, clearInvalidRole) {
    const environment = row.querySelector('[data-access-field="environment"]');
    const role = row.querySelector('[data-access-field="role"]');
    const sandbox = role?.querySelector('[data-development-only]');

    if (!environment || !role || !sandbox) return;

    const sandboxAllowed = environment.value === 'development';
    sandbox.disabled = !sandboxAllowed;
    sandbox.hidden = !sandboxAllowed;
    if (clearInvalidRole && !sandboxAllowed && role.value === 'sandbox') role.value = '';
  }

  function updateControls() {
    const currentRows = rows();
    currentRows.forEach((row, index) => {
      row.querySelector('[data-access-row-title]').textContent = `Access ${index + 1}`;
      const removeButton = row.querySelector('[data-remove-access-row]');
      removeButton.hidden = currentRows.length === 1;
      removeButton.setAttribute('aria-label', `Remove access ${index + 1}`);
    });
    addButton.disabled = currentRows.length >= maximumRows;
  }

  function prepareNewRow(row, index) {
    row.dataset.rowIndex = index;
    row.querySelectorAll('[data-access-field]').forEach((field) => {
      const label = row.querySelector(`label[for="${field.id}"]`);
      field.id = `${field.name}-${index}`;
      field.value = '';
      if (label) label.htmlFor = field.id;
    });
  }

  addButton.addEventListener('click', () => {
    if (rows().length >= maximumRows) return;

    const fragment = template.content.cloneNode(true);
    const newRow = fragment.querySelector('[data-access-row]');
    prepareNewRow(newRow, nextIndex);
    nextIndex += 1;
    list.appendChild(newRow);
    updateRoleOptions(newRow, false);
    updateControls();
    newRow.querySelector('[data-access-field="application"]').focus();
    if (status) status.textContent = `Row ${rows().length} added`;
  });

  list.addEventListener('click', (event) => {
    const removeButton = event.target.closest('[data-remove-access-row]');
    if (!removeButton || rows().length === 1) return;

    removeButton.closest('[data-access-row]').remove();
    updateControls();
    addButton.focus();
    if (status) status.textContent = 'Access removed';
  });

  list.addEventListener('change', (event) => {
    if (event.target.matches('[data-access-field="environment"]')) {
      updateRoleOptions(event.target.closest('[data-access-row]'), true);
    }
  });

  rows().forEach((row) => updateRoleOptions(row, false));
  updateControls();
})();