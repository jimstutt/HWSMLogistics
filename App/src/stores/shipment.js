// ~/Dev/NGOL-D/App/src/stores/shipment.js
// Spec: NGOLTechSpec.md — Real-time Updates with Socket.IO
import { ref } from 'vue';
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000', {
  transports: ['websocket'], // ← avoids polling 400
  path: '/socket.io',        // ← explicit path
});

const shipments = ref([]);

socket.on('connect', () => {
  console.log('✅ Socket.IO connected');
});

socket.on('shipmentUpdate', (data) => {
  console.log('📦 Shipment update:', data);
  // Update local state
});

export { socket, shipments };
