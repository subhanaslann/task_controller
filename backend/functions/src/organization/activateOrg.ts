import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { handleError, NotFoundError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

export const activateOrg = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    // TEAM_MANAGER can only activate their own organization
    const { organizationId } = context;
    const db = admin.firestore();

    const orgRef = db.collection('organizations').doc(organizationId);
    const orgDoc = await orgRef.get();

    if (!orgDoc.exists) {
      throw new NotFoundError('Organization not found');
    }

    await orgRef.update({
      isActive: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: 'Organization activated successfully' };
  } catch (error) {
    throw handleError(error);
  }
});
