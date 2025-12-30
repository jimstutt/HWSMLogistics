const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

// Create API service instance
const api = {
  // Authentication endpoints
  auth: {
    login: async (credentials) => {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(credentials)
      })
      
      if (!response.ok) {
        const error = await response.json().catch(() => ({}))
        throw new Error(error.message || 'Authentication failed')
      }
      
      return response.json()
    },
    
    logout: async () => {
      const token = localStorage.getItem('ngol_token')
      
      const response = await fetch(`${API_BASE_URL}/auth/logout`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      
      if (!response.ok) {
        throw new Error('Logout failed')
      }
      
      return response.json()
    }
  },
  
  // Example protected endpoint
  dashboard: {
    getStats: async () => {
      const token = localStorage.getItem('ngol_token')
      
      const response = await fetch(`${API_BASE_URL}/dashboard/stats`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      
      if (!response.ok) {
        throw new Error('Failed to fetch dashboard data')
      }
      
      return response.json()
    }
  }
}

export default api
