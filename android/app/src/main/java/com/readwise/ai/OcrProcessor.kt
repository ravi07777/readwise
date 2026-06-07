package com.readwise.ai

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext


class OcrProcessor {

    companion object {
        private const val TAG = "OcrProcessor"
    }

    private val latinRecognizer: TextRecognizer by lazy {
        TextRecognition.getClient(TextRecognizerOptions.Builder().build())
    }

    private val chineseRecognizer: TextRecognizer by lazy {
        TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
    }

    private val japaneseRecognizer: TextRecognizer by lazy {
        TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build())
    }

    private val koreanRecognizer: TextRecognizer by lazy {
        TextRecognition.getClient(KoreanTextRecognizerOptions.Builder().build())
    }

    sealed class OcrResult {
        data class Success(val text: String, val confidence: Float = 1.0f) : OcrResult()
        data class Error(val message: String) : OcrResult()
    }

    suspend fun recognizeText(byteArray: ByteArray): OcrResult = withContext(Dispatchers.IO) {
        try {
            val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
            if (bitmap == null) {
                return@withContext OcrResult.Error("Failed to decode bitmap")
            }
            recognizeBitmap(bitmap)
        } catch (e: Exception) {
            Log.e(TAG, "OCR failed", e)
            OcrResult.Error(e.message ?: "Unknown OCR error")
        }
    }

    private suspend fun recognizeBitmap(bitmap: Bitmap): OcrResult = withContext(Dispatchers.IO) {
        try {
            val inputImage = InputImage.fromBitmap(bitmap, 0)

            val result = processWithRecognizer(latinRecognizer, inputImage)

            val finalResult = if (result.text.length < 10) {
                val candidates = listOf(
                    chineseRecognizer to "Chinese",
                    japaneseRecognizer to "Japanese",
                    koreanRecognizer to "Korean"
                )

                var bestResult = result
                for ((recognizer, name) in candidates) {
                    try {
                        val candidateResult = processWithRecognizer(recognizer, inputImage)
                        if (candidateResult.text.length > bestResult.text.length) {
                            bestResult = candidateResult
                        }
                    } catch (e: Exception) {
                        Log.d(TAG, "$name OCR failed: ${e.message}")
                    }
                }
                bestResult
            } else {
                result
            }

            val lineConfidences = finalResult.textBlocks.flatMap { it.lines }.map { it.confidence }
            val confidence = if (lineConfidences.isNotEmpty()) {
                val highConfLines = lineConfidences.count { it >= 0.8f }
                highConfLines.toFloat() / lineConfidences.size
            } else {
                0.5f
            }

            OcrResult.Success(text = finalResult.text, confidence = confidence)
        } catch (e: Exception) {
            Log.e(TAG, "OCR bitmap failed", e)
            OcrResult.Error(e.message ?: "Unknown OCR error")
        }
    }

    private suspend fun processWithRecognizer(
        recognizer: TextRecognizer,
        inputImage: InputImage
    ): com.google.mlkit.vision.text.Text = suspendCancellableCoroutine { cont ->
        recognizer.process(inputImage)
            .addOnSuccessListener { text ->
                if (cont.isActive) {
                    cont.resume(text) {}
                }
            }
            .addOnFailureListener { e ->
                if (cont.isActive) {
                    cont.resumeWith(Result.failure(e))
                }
            }
    }
}
