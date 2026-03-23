import SwiftUI

struct AudioClipView: View {
    let recordings: [Data]
    let audioRecorder: AudioRecorder
    let onDelete: (Int) -> Void

    /// Fixed waveform heights generated once, not on every render
    private static let waveformHeights: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: 4...16) }

    var body: some View {
        if !recordings.isEmpty {
            VStack(spacing: 4) {
                ForEach(Array(recordings.enumerated()), id: \.offset) { index, data in
                    audioRow(data: data, index: index)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private func audioRow(data: Data, index: Int) -> some View {
        HStack(spacing: 8) {
            Button {
                if audioRecorder.isPlaying && audioRecorder.playingIndex == index {
                    audioRecorder.stopPlayback()
                } else {
                    audioRecorder.play(data: data, index: index)
                }
            } label: {
                Image(systemName: (audioRecorder.isPlaying && audioRecorder.playingIndex == index) ? "stop.fill" : "play.fill")
                    .font(.system(size: 11))
                    .frame(width: 22, height: 22)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(audioRecorder.isPlaying && audioRecorder.playingIndex == index ? "Stop" : "Play")

            RoundedRectangle(cornerRadius: 2)
                .fill(.primary.opacity(0.15))
                .frame(height: 20)
                .overlay(
                    HStack(spacing: 2) {
                        ForEach(0..<12, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(.primary.opacity(0.4))
                                .frame(width: 2, height: Self.waveformHeights[i])
                        }
                    }
                )

            if let duration = audioRecorder.durationOf(data: data) {
                Text(duration.formattedDuration)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Button { onDelete(index) } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete recording")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
