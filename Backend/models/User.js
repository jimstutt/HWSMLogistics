// ~/Dev/NGOL-D/Backend/models/User.js
// Spec: NGOLTechSpec.md — Demo user
export const findUserByEmail = (email) => {
  // ✅ Hardcoded demo user (spec-compliant)
  if (email === 'admin@example.org') {
    return {
      id: 1,
      email: 'admin@example.org',
      password: 'password123',  // plaintext for demo (spec allows it)
      role: 'admin'
    };
  }
  return null;
};
