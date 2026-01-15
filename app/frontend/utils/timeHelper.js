export function getTimeRelative(isoDate) {
  if (!isoDate) return ''
  
  try {
    const date = new Date(isoDate)
    if (isNaN(date)) return isoDate
    
    const now = new Date()
    const secondsAgo = Math.floor((now - date) / 1000)
    
    if (secondsAgo < 60) return 'agora'
    if (secondsAgo < 3600) return `${Math.floor(secondsAgo / 60)}m atrás`
    if (secondsAgo < 86400) return `${Math.floor(secondsAgo / 3600)}h atrás`
    if (secondsAgo < 604800) return `${Math.floor(secondsAgo / 86400)}d atrás`
    
    const dd = String(date.getDate()).padStart(2, '0')
    const mm = String(date.getMonth() + 1).padStart(2, '0')
    const yyyy = date.getFullYear()
    return `${dd}/${mm}/${yyyy}`
  } catch (e) {
    return isoDate
  }
}

export function getInitials(name) {
  if (!name) return 'U'
  return name
    .split(' ')
    .slice(0, 2)
    .map(part => part.charAt(0).toUpperCase())
    .join('')
}
