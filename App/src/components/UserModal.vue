<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h3>{{ mode === 'add' ? 'Add User' : 'Edit User' }}</h3>
        <button class="close-btn" @click="close">×</button>
      </div>
      
      <form @submit.prevent="save" class="modal-form">
        <div class="form-group">
          <label for="firstName">First Name *</label>
          <input
            id="firstName"
            v-model="formData.firstName"
            type="text"
            required
            placeholder="Enter first name"
          >
        </div>

        <div class="form-group">
          <label for="lastName">Last Name *</label>
          <input
            id="lastName"
            v-model="formData.lastName"
            type="text"
            required
            placeholder="Enter last name"
          >
        </div>

        <div class="form-group">
          <label for="email">Email *</label>
          <input
            id="email"
            v-model="formData.email"
            type="email"
            required
            placeholder="Enter email address"
          >
        </div>

        <div class="form-group">
          <label for="organization">Organization *</label>
          <select id="organization" v-model="formData.organization" required>
            <option value="">Select Organization</option>
            <option value="Red Cross">Red Cross</option>
            <option value="UNHCR">UNHCR</option>
            <option value="World Food Programme">World Food Programme</option>
            <option value="Doctors Without Borders">Doctors Without Borders</option>
            <option value="Oxfam">Oxfam</option>
          </select>
        </div>

        <div class="form-group">
          <label for="role">Role *</label>
          <select id="role" v-model="formData.role" required>
            <option value="">Select Role</option>
            <option value="Admin">Admin</option>
            <option value="Logistics">Logistics</option>
            <option value="Field">Field</option>
            <option value="Viewer">Viewer</option>
          </select>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="close">Cancel</button>
          <button type="submit" class="btn btn-primary">Save</button>
        </div>
<div class="form-group">
<label for="mobile">Mobile *</label>
<input id="mobile" v-model="formData.mobile" type="tel" required placeholder="e.g. +254712345678" />
</div>
<div class="form-group">
<label for="whatsapp">WhatsApp</label>
<input id="whatsapp" v-model="formData.whatsapp" type="tel" placeholder="e.g. +254712345678" />
</div>
<div class="form-group">
<label for="landline">Landline</label>
<input id="landline" v-model="formData.landline" type="tel" placeholder="e.g. +25420123456" />
</div>
<div class="form-group">
<label for="mobile">Mobile *</label>
<input id="mobile" v-model="formData.mobile" type="tel" required placeholder="e.g. +254712345678" />
</div>
<div class="form-group">
<label for="whatsapp">WhatsApp</label>
<input id="whatsapp" v-model="formData.whatsapp" type="tel" placeholder="e.g. +254712345678" />
</div>
<div class="form-group">
<label for="landline">Landline</label>
<input id="landline" v-model="formData.landline" type="tel" placeholder="e.g. +25420123456" />
</div>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, watch } from 'vue'

export default {
  name: 'UserModal',
  props: {
    user: Object,
    mode: String
  },
  emits: ['save', 'close'],
  setup(props, { emit }) {
const formData = ref({
firstName: "",
lastName: "",
email: "",
organization: "",
role: "",
mobile: "",
whatsapp: "",
landline: ""
})
firstName: "",
lastName: "",
email: "",
organization: "",
role: "",
mobile: "",
whatsapp: "",
landline: ""
})
      firstName: '',
      lastName: '',
      email: '',
      organization: '',
      role: ''
    })

    // Initialize form data when editing
    watch(() => props.user, (newUser) => {
      if (newUser && props.mode === 'edit') {
        formData.value = {
          firstName: newUser.firstName || '',
          lastName: newUser.lastName || '',
          email: newUser.email || '',
          organization: newUser.organization || '',
          role: newUser.role || ''
        }
      } else {
        formData.value = {
          firstName: '',
          lastName: '',
          email: '',
          organization: '',
          role: ''
        }
      }
    }, { immediate: true })

    const save = () => {
emit('save', {
firstName: formData.value.firstName,
lastName: formData.value.lastName,
email: formData.value.email,
organization: formData.value.organization,
role: formData.value.role,
mobile: formData.value.mobile,
whatsapp: formData.value.whatsapp,
landline: formData.value.landline,
id: props.user?.id
})
firstName: formData.value.firstName,
lastName: formData.value.lastName,
email: formData.value.email,
organization: formData.value.organization,
role: formData.value.role,
mobile: formData.value.mobile,
whatsapp: formData.value.whatsapp,
landline: formData.value.landline,
id: props.user?.id
})
        ...formData.value,
        id: props.user?.id
      })
    }

    const close = () => {
      emit('close')
    }

    return {
      formData,
      save,
      close
    }
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 500px;
  max-width: 90%;
  max-height: 90%;
  overflow-y: auto;
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #666;
}

.close-btn:hover {
  color: #333;
}

.modal-form {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #333;
  font-weight: 500;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #007bff;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e0e0e0;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.3s;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover {
  background: #545b62;
}
</style>
