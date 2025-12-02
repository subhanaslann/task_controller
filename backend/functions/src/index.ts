import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Auth functions
export { loginUser } from './auth/loginUser';
export { registerTeam } from './auth/registerTeam';

// Task functions
export { createTask, createMemberTask } from './tasks/createTask';
export { updateTask, updateMemberTask } from './tasks/updateTask';
export { deleteTask, deleteMemberTask } from './tasks/deleteTask';
export { updateTaskStatus } from './tasks/updateTaskStatus';

// User functions
export { createUser } from './users/createUser';
export { updateUser } from './users/updateUser';
export { deleteUser } from './users/deleteUser';
export { updateProfile } from './users/updateProfile';

// Topic functions
export { createTopic } from './topics/createTopic';
export { updateTopic } from './topics/updateTopic';
export { deleteTopic } from './topics/deleteTopic';

// Organization functions
export { updateOrganization, getOrganizationStats } from './organization/updateOrganization';
export { activateOrg } from './organization/activateOrg';
export { deactivateOrg } from './organization/deactivateOrg';
