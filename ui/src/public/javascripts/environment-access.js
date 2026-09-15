(() => {
  const roleCheckboxes = [...document.querySelectorAll('[data-sso-role-checkbox]')];

  if (roleCheckboxes.length === 0) return;

  const inputFor = (checkbox) => document.getElementById(checkbox.dataset.ssoGroupField);
  const selectedInputs = () => roleCheckboxes.filter((checkbox) => checkbox.checked).map(inputFor);
  const firstPopulatedInput = (excludedInput) =>
    selectedInputs().find(
      (input) => input !== excludedInput && input && input.value.trim().length > 0
    );

  function updateCopyButtons() {
    const firstInput = firstPopulatedInput();

    document.querySelectorAll('[data-copy-sso-group]').forEach((button) => {
      const targetInput = document.getElementById(button.dataset.copySsoGroup);
      button.hidden = !firstInput || targetInput === firstInput;
    });
  }

  roleCheckboxes.forEach((checkbox) => {
    const input = inputFor(checkbox);

    checkbox.addEventListener('change', () => {
      if (checkbox.checked && input && input.value.trim() === '') {
        const firstInput = firstPopulatedInput(input);
        if (firstInput) input.value = firstInput.value;
      }
      updateCopyButtons();
    });

    input.addEventListener('input', updateCopyButtons);
  });

  document.querySelectorAll('[data-copy-sso-group]').forEach((button) => {
    button.addEventListener('click', () => {
      const targetInput = document.getElementById(button.dataset.copySsoGroup);
      const firstInput = firstPopulatedInput(targetInput);
      if (firstInput) {
        targetInput.value = firstInput.value;
        targetInput.focus();
      }
    });
  });

  updateCopyButtons();
})();