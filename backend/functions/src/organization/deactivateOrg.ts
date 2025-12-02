import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { orgIdSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError } from '../utils/errors';
import { requireAuth, requireAdmin } from '../utils/auth';

export const deactivateOrg = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireAdmin(context);

    const validationResult = orgIdSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { organizationId } = validationResult.data;
    const db = admin.firestore();

    const orgRef = db.collection('organizations').doc(organizationId);
    const orgDoc = await orgRef.get();

    if (!orgDoc.exists) {
      throw new NotFoundError('Organization not found');
    }

    await orgRef.update({
      isActive: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: 'Organization deactivated successfully' };
  } catch (error) {
    throw handleError(error);
  }
});
