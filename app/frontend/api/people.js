async function jsonFetch(path, opts = {}) {
  const headers = Object.assign({}, opts.headers || {})

  // Attach Rails CSRF token from meta tag to protect non-GET requests
  try {
    const tokenMeta = document.querySelector('meta[name="csrf-token"]')
    if (tokenMeta && tokenMeta.content) headers['X-CSRF-Token'] = tokenMeta.content
  } catch (e) {
    // SSR or non-browser environment: ignore
  }

  if (!(opts.body instanceof FormData)) {
    headers["Content-Type"] = "application/json"
  }

  const res = await fetch(path, Object.assign({ credentials: 'same-origin', headers }, opts))
  if (!res.ok) {
    const text = await res.text()
    let data = {}
    try { data = JSON.parse(text) } catch(e) { data = { error: text } }
    throw data
  }
  if (res.status === 204) return null
  return res.json()
}

export async function fetchPeople() { return jsonFetch('/people') }
export async function fetchPerson(id) { return jsonFetch(`/people/${id}`) }
export async function createPerson(payload) { return jsonFetch('/people', { method: 'POST', body: JSON.stringify({ person: payload }) }) }
export async function updatePerson(id, payload) { return jsonFetch(`/people/${id}`, { method: 'PUT', body: JSON.stringify({ person: payload }) }) }
export async function deletePerson(id) { return jsonFetch(`/people/${id}`, { method: 'DELETE' }) }
