const wrapper = document.getElementById('wrapper');
const list = document.getElementById('job-list');
const closeBtn = document.getElementById('close');

let jobs = [];

function render() {
  list.innerHTML = '';
  jobs.forEach(job => {
    const item = document.createElement('div');
    item.className = 'job';
    item.innerHTML = `
      <div>
        <div class="job-label">${job.label}</div>
        <div class="job-grade">Grade: ${job.grade}</div>
        ${job.salary ? `<div class="job-salary">Pays: $${job.salary}</div>` : ''}
      </div>
      <div class="actions">
        <button class="btn ${job.onDuty ? 'btn-success' : 'btn-secondary'}" data-action="toggleDuty" data-job="${job.job}">
          ${job.onDuty ? 'On Duty' : 'Off Duty'}
        </button>
        <button class="btn btn-primary" data-action="selectJob" data-job="${job.job}">Set Active</button>
        <button class="btn btn-danger" data-action="removeJob" data-job="${job.job}">Quit</button>
      </div>
    `;
    list.appendChild(item);
  });
}

function show() {
  wrapper.classList.remove('hidden');
  setTimeout(() => wrapper.classList.add('show'), 10);
}
function hide() {
  wrapper.classList.remove('show');
  setTimeout(() => wrapper.classList.add('hidden'), 200);
}

window.addEventListener('message', (e) => {
  const d = e.data;
  if (d.action === 'showJobs') { jobs = d.jobs || []; show(); render(); }
  else if (d.action === 'update') { jobs = d.jobs || jobs; render(); }
  else if (d.action === 'hide') { hide(); }
});

closeBtn.addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
  hide();
});

list.addEventListener('click', (e) => {
  const btn = e.target.closest('button');
  if (!btn) return;
  fetch(`https://${GetParentResourceName()}/${btn.dataset.action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ job: btn.dataset.job })
  });
});
