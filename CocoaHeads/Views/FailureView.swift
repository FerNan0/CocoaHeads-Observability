import SwiftUI

struct FailureView: View {
    let error: BackendError
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)

            Image(systemName: "xmark.octagon.fill")
                .font(.system(size: 78))
                .foregroundStyle(.red)

            VStack(spacing: 10) {
                Text(failureTitle)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                Text(failureMessage)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text("Ok, entendi")
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

    private var failureTitle: String {
        switch error {
        case .custom:
            return "Falha"
        case .generic:
            return "Falha"
        }
    }

    private var failureMessage: String {
        switch error {
        case let .custom(customError):
            return customError.userMessage ?? customError.message
        case .generic:
            return "genericError"
        }
    }
}
