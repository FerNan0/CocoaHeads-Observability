import SwiftUI

struct SuccessView: View {
    let response: PromoResponse
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 78))
                .foregroundStyle(.green)

            VStack(spacing: 10) {
                Text(response.title ?? "Sucesso")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                if let subtitle = response.subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Button {
                openDeeplink()
            } label: {
                Text(response.cta ?? "Abrir deeplink")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openDeeplink() {
        guard let deeplink = response.deeplink else {
            logDeeplinkFailure(deeplink: "nil", reason: "missing_deeplink")
            return
        }

        guard let url = URL(string: deeplink) else {
            logDeeplinkFailure(deeplink: deeplink, reason: "invalid_deeplink")
            return
        }

        openURL(url) { accepted in
            if !accepted {
                logDeeplinkFailure(deeplink: deeplink, reason: "open_url_rejected")
            }
        }
    }

    private func logDeeplinkFailure(deeplink: String, reason: String) {
        let model = ObservabilityModel.from(
            .deepLinkFailed(url: deeplink),
            additionalMetadata: [
                "screen": "SuccessView",
                "reason": reason
            ]
        )

        OpenSearchObservabilityClient().log(model)
    }
}
