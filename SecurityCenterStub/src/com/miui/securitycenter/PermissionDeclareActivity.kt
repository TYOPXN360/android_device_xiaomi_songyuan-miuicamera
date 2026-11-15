/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.miui.securitycenter

import android.app.Activity
import android.os.Bundle
import android.util.Log

/**
 * Answers MIUICamera's privacy declaration request immediately.
 *
 * On first launch the camera resolves miui.intent.action.SYSTEM_PERMISSION_DECLARE_NEW
 * (falling back to SYSTEM_PERMISSION_DECLARE), starts it with
 * setPackage("com.miui.securitycenter") and treats result code 1 or 0x904 as
 * "the user agreed". Nothing on this build answers that, so mIsNewCTAShowing
 * never clears, setupCamera is skipped and the viewfinder stays frozen.
 *
 * Returning the accepted code from here lets the camera finish its permission
 * check without any interaction, so it can run on its normal China
 * configuration instead of being pushed down the global path - which would load
 * global camera configuration against China vendor tuning.
 */
class PermissionDeclareActivity : Activity() {

    companion object {
        private const val TAG = "SecurityCenterStub"

        /** The result code the camera reads as "the user agreed". */
        private const val RESULT_CTA_ACCEPTED = 1
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "declaring permissions for ${callingPackage} action=${intent?.action}")
        setResult(RESULT_CTA_ACCEPTED)
        finish()
    }
}
