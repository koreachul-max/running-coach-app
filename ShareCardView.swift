import SwiftUI

struct ShareCardView: View {
    var title: String
    var subtitle: String
    var stats: String
    var footer: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 52, weight: .bold))
                    Text(subtitle)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 12) {
                    Text("This week's training")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(stats)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Text(footer)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(16)
            }
            .padding(36)
        }
        .frame(width: 1080, height: 1080)
    }
}
