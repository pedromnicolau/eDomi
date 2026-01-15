const base = "/kanban_"

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

export async function fetchBoards() { return jsonFetch('/kanban_boards') }
export async function fetchBoard(id) { return jsonFetch(`/kanban_boards/${id}`) }
export async function createBoard(payload) { return jsonFetch('/kanban_boards', { method: 'POST', body: JSON.stringify({ kanban_board: payload }) }) }
export async function updateBoard(id, payload) { return jsonFetch(`/kanban_boards/${id}`, { method: 'PUT', body: JSON.stringify({ kanban_board: payload }) }) }

export async function createColumn(payload) {
  const headers = {}
  try {
    const tokenMeta = document.querySelector('meta[name="csrf-token"]')
    if (tokenMeta && tokenMeta.content) headers['X-CSRF-Token'] = tokenMeta.content
  } catch (e) {
    // SSR or non-browser environment: ignore
  }
  const body = { kanban_column: payload }
  headers['Content-Type'] = 'application/json'
  const res = await fetch('/kanban_columns', {
    method: 'POST',
    body: JSON.stringify(body),
    credentials: 'same-origin',
    headers
  })
  if (!res.ok) {
    const text = await res.text()
    let data = {}
    try { data = JSON.parse(text) } catch(e) { data = { error: text } }
    throw data
  }
  return res.json()
}
export async function updateColumn(id, payload) {
  const headers = {}
  try {
    const tokenMeta = document.querySelector('meta[name="csrf-token"]')
    if (tokenMeta && tokenMeta.content) headers['X-CSRF-Token'] = tokenMeta.content
  } catch (e) {
    // SSR or non-browser environment: ignore
  }
  const body = { kanban_column: payload }
  headers['Content-Type'] = 'application/json'
  const res = await fetch(`/kanban_columns/${id}`, {
    method: 'PUT',
    body: JSON.stringify(body),
    credentials: 'same-origin',
    headers
  })
  if (!res.ok) {
    const text = await res.text()
    let data = {}
    try { data = JSON.parse(text) } catch(e) { data = { error: text } }
    throw data
  }
  return res.json()
}
export async function deleteColumn(id) { return jsonFetch(`/kanban_columns/${id}`, { method: 'DELETE' }) }
export async function reorderColumns(columns) { return jsonFetch('/kanban_columns/reorder', { method: 'POST', body: JSON.stringify({ columns }) }) }

export async function createCard(payload, attachments) {
  const headers = {}
  try {
    const tokenMeta = document.querySelector('meta[name="csrf-token"]')
    if (tokenMeta && tokenMeta.content) headers['X-CSRF-Token'] = tokenMeta.content
  } catch (e) {}
  
  const fd = new FormData()
  fd.append('kanban_card[title]', payload.title)
  fd.append('kanban_card[description]', payload.description || '')
  fd.append('kanban_card[kanban_column_id]', payload.kanban_column_id)
  if (payload.assigned_user_id) fd.append('kanban_card[assigned_user_id]', payload.assigned_user_id)
  if (payload.client_info) fd.append('kanban_card[client_info]', JSON.stringify(payload.client_info))
  if (payload.tags) fd.append('kanban_card[tags]', JSON.stringify(payload.tags))
  if (attachments) {
    attachments.forEach(f => fd.append('attachments[]', f))
  }
  const res = await fetch('/kanban_cards', { method: 'POST', body: fd, credentials: 'same-origin', headers })
  if (!res.ok) {
    const text = await res.text()
    let data = {}
    try { data = JSON.parse(text) } catch(e) { data = { error: text } }
    throw data
  }
  return res.json()
}

export async function updateCard(id, payload, attachments = null, removeAttachmentIds = null) {
  const headers = {}
  try {
    const tokenMeta = document.querySelector('meta[name="csrf-token"]')
    if (tokenMeta && tokenMeta.content) headers['X-CSRF-Token'] = tokenMeta.content
  } catch (e) {}
  
  const fd = new FormData()
  if (payload.title) fd.append('kanban_card[title]', payload.title)
  if (payload.description) fd.append('kanban_card[description]', payload.description)
  if (payload.kanban_column_id) fd.append('kanban_card[kanban_column_id]', payload.kanban_column_id)
  if (payload.assigned_user_id) fd.append('kanban_card[assigned_user_id]', payload.assigned_user_id)
  if (payload.client_info) fd.append('kanban_card[client_info]', JSON.stringify(payload.client_info))
  if (payload.tags) fd.append('kanban_card[tags]', JSON.stringify(payload.tags))
  if (payload.checklist) fd.append('kanban_card[checklist]', JSON.stringify(payload.checklist))
  if (attachments) attachments.forEach(f => fd.append('attachments[]', f))
  if (removeAttachmentIds && removeAttachmentIds.length > 0) {
    removeAttachmentIds.forEach(id => fd.append('remove_attachment_blob_ids[]', id))
  }
  const res = await fetch(`/kanban_cards/${id}`, { method: 'PUT', body: fd, credentials: 'same-origin', headers })
  if (!res.ok) {
    const text = await res.text()
    let data = {}
    try { data = JSON.parse(text) } catch(e) { data = { error: text } }
    throw data
  }
  return res.json()
}

export async function deleteCard(id) { return jsonFetch(`/kanban_cards/${id}`, { method: 'DELETE' }) }
export async function reorderCards(cards) { return jsonFetch('/kanban_cards/reorder', { method: 'POST', body: JSON.stringify({ cards }) }) }

export async function fetchComments(cardId) {
  return jsonFetch(`/kanban_cards/${cardId}/comments`)
}

export async function addComment(cardId, body) {
  return jsonFetch(`/kanban_cards/${cardId}/comments`, {
    method: 'POST',
    body: JSON.stringify({ comment: { body } })
  })
}

export async function addReply(cardId, commentId, body) {
  return jsonFetch(`/kanban_cards/${cardId}/comments/create_reply`, {
    method: 'POST',
    body: JSON.stringify({ comment: { body }, comment_id: commentId })
  })
}

export async function likeComment(commentId) {
  return jsonFetch(`/kanban_comments/${commentId}/like`, {
    method: 'POST'
  })
}

export async function unlikeComment(commentId) {
  return jsonFetch(`/kanban_comments/${commentId}/unlike`, {
    method: 'DELETE'
  })
}

export async function addReaction(commentId, emoji) {
  return jsonFetch(`/kanban_comments/${commentId}/add_reaction`, {
    method: 'POST',
    body: JSON.stringify({ emoji })
  })
}

export async function removeReaction(commentId, emoji) {
  return jsonFetch(`/kanban_comments/${commentId}/remove_reaction`, {
    method: 'DELETE',
    body: JSON.stringify({ emoji })
  })
}
