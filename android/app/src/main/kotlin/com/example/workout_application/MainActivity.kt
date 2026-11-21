package com.example.workout_application

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.workout_application/rest_sound"
        private const val SAMPLE_RATE = 44100
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "playRestSound") {
                    val soundType = call.argument<String>("soundType") ?: "gymBeep"
                    playRestSoundAsync(soundType)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun playRestSoundAsync(soundType: String) {
        thread(start = true, name = "RestSoundThread") {
            try {
                triggerVibration()
                if (soundType == "systemDefault") {
                    playSystemNotificationSound()
                    return@thread
                }

                val samples = when (soundType) {
                    "boxingBell" -> synthesizeBoxingBell()
                    "chimeFanfare" -> synthesizeChimeFanfare()
                    "digitalAlarm" -> synthesizeDigitalAlarm()
                    else -> synthesizeGymBeep()
                }
                playPcmSamples(samples)
            } catch (_: Throwable) {
                // Ignore audio playback errors on unsupported devices.
            }
        }
    }

    private fun triggerVibration() {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vm?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }
            if (vibrator?.hasVibrator() == true) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(
                        VibrationEffect.createWaveform(longArrayOf(0, 140, 80, 220), -1)
                    )
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(300)
                }
            }
        } catch (_: Throwable) {
        }
    }

    private fun playSystemNotificationSound() {
        try {
            var uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            if (uri == null) {
                uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            }
            val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                ringtone?.audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            }
            ringtone?.play()
        } catch (_: Throwable) {
        }
    }

    private fun playPcmSamples(samples: ShortArray) {
        val byteCount = samples.size * 2
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val audioFormat = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(SAMPLE_RATE)
            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
            .build()

        val minBuf = AudioTrack.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val bufferSize = maxOf(byteCount, minBuf)

        val track = AudioTrack.Builder()
            .setAudioAttributes(audioAttributes)
            .setAudioFormat(audioFormat)
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build()

        track.write(samples, 0, samples.size)
        track.play()

        val durationMs = (samples.size * 1000L) / SAMPLE_RATE + 150L
        Thread.sleep(durationMs)
        track.stop()
        track.release()
    }

    /**
     * Gym Timer Beep: Two short 880 Hz beeps followed by one longer 1760 Hz high beep.
     */
    private fun synthesizeGymBeep(): ShortArray {
        val seg1 = toneSegment(freqHz = 880.0, durationMs = 115, amplitude = 0.75)
        val gap1 = silenceSegment(durationMs = 65)
        val seg2 = toneSegment(freqHz = 880.0, durationMs = 115, amplitude = 0.75)
        val gap2 = silenceSegment(durationMs = 65)
        val seg3 = toneSegment(freqHz = 1760.0, durationMs = 360, amplitude = 0.85)
        return concatSegments(seg1, gap1, seg2, gap2, seg3)
    }

    /**
     * Boxing / Gym Round Bell: Double metallic bell strike with harmonic overtones.
     */
    private fun synthesizeBoxingBell(): ShortArray {
        val strike1 = bellStrikeSegment(durationMs = 420)
        val strike2 = bellStrikeSegment(durationMs = 750)
        return concatSegments(strike1, strike2)
    }

    private fun bellStrikeSegment(durationMs: Int): ShortArray {
        val count = (SAMPLE_RATE * durationMs) / 1000
        val out = ShortArray(count)
        for (i in 0 until count) {
            val t = i.toDouble() / SAMPLE_RATE
            val env = exp(-4.8 * t)
            val w1 = sin(2.0 * PI * 1046.5 * t) * 0.50
            val w2 = sin(2.0 * PI * 1568.0 * t) * 0.28 * exp(-6.0 * t)
            val w3 = sin(2.0 * PI * 2217.4 * t) * 0.15 * exp(-8.5 * t)
            val w4 = sin(2.0 * PI * 2960.0 * t) * 0.07 * exp(-11.0 * t)
            val sample = (w1 + w2 + w3 + w4) * env * 0.9
            out[i] = (sample.coerceIn(-1.0, 1.0) * Short.MAX_VALUE).toInt().toShort()
        }
        return out
    }

    /**
     * Energetic Chime: Ascending C5 -> E5 -> G5 -> C6 major arpeggio.
     */
    private fun synthesizeChimeFanfare(): ShortArray {
        val c5 = chimeNoteSegment(523.25, 110)
        val e5 = chimeNoteSegment(659.25, 110)
        val g5 = chimeNoteSegment(783.99, 110)
        val c6 = chimeNoteSegment(1046.50, 380)
        return concatSegments(c5, e5, g5, c6)
    }

    private fun chimeNoteSegment(freqHz: Double, durationMs: Int): ShortArray {
        val count = (SAMPLE_RATE * durationMs) / 1000
        val out = ShortArray(count)
        for (i in 0 until count) {
            val t = i.toDouble() / SAMPLE_RATE
            val env = exp(-3.5 * t)
            val fundamental = sin(2.0 * PI * freqHz * t) * 0.75
            val overtone = sin(2.0 * PI * (freqHz * 2.0) * t) * 0.25 * exp(-6.0 * t)
            val sample = (fundamental + overtone) * env * 0.85
            out[i] = (sample.coerceIn(-1.0, 1.0) * Short.MAX_VALUE).toInt().toShort()
        }
        return out
    }

    /**
     * Digital Double Alarm: Classic rapid digital watch double-beep x2.
     */
    private fun synthesizeDigitalAlarm(): ShortArray {
        val pulse = toneSegment(freqHz = 2048.0, durationMs = 75, amplitude = 0.8)
        val shortGap = silenceSegment(durationMs = 55)
        val longGap = silenceSegment(durationMs = 150)
        return concatSegments(pulse, shortGap, pulse, longGap, pulse, shortGap, pulse)
    }

    private fun toneSegment(freqHz: Double, durationMs: Int, amplitude: Double): ShortArray {
        val count = (SAMPLE_RATE * durationMs) / 1000
        val out = ShortArray(count)
        val fadeSamples = minOf(count / 8, 250)
        for (i in 0 until count) {
            val t = i.toDouble() / SAMPLE_RATE
            var env = 1.0
            if (i < fadeSamples) {
                env = i.toDouble() / fadeSamples
            } else if (i > count - fadeSamples) {
                env = (count - i).toDouble() / fadeSamples
            }
            val wave = sin(2.0 * PI * freqHz * t) * amplitude * env
            out[i] = (wave.coerceIn(-1.0, 1.0) * Short.MAX_VALUE).toInt().toShort()
        }
        return out
    }

    private fun silenceSegment(durationMs: Int): ShortArray {
        val count = (SAMPLE_RATE * durationMs) / 1000
        return ShortArray(count)
    }

    private fun concatSegments(vararg segments: ShortArray): ShortArray {
        val total = segments.sumOf { it.size }
        val result = ShortArray(total)
        var offset = 0
        for (seg in segments) {
            System.arraycopy(seg, 0, result, offset, seg.size)
            offset += seg.size
        }
        return result
    }
}
