// AboutView.swift
// Purpose: About dialog for FinanceMate application
// Part of comprehensive UX validation and completion

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 5)

            Text(LegalContent.appInfo.name)
                .font(CentralizedTheme.shared.largeTitleFont)
                .fontWeight(.bold)

            Text("Version \(LegalContent.versionInfo.version)")
                .font(CentralizedTheme.shared.subheadlineFont)
                .foregroundColor(CentralizedTheme.shared.secondaryTextColor)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("About \(LegalContent.appInfo.name)")
                        .font(CentralizedTheme.shared.title2Font)
                        .fontWeight(.semibold)
                    
                    Text(LegalContent.appInfo.description)
                        .font(CentralizedTheme.shared.bodyFont)
                        .lineSpacing(5)

                    Text("Key Features:")
                        .font(CentralizedTheme.shared.title3Font)
                        .fontWeight(.semibold)
                        .padding(.top, 10)

                    ForEach(LegalContent.features) { feature in
                        HStack(alignment: .top) {
                            Image(systemName: feature.icon)
                                .foregroundColor(CentralizedTheme.shared.accentColor)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(feature.title)
                                    .fontWeight(.bold)
                                Text(feature.description)
                            }
                        }
                        .font(CentralizedTheme.shared.bodyFont)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            Button("Visit our Website") {
                if let url = URL(string: "https://www.financemate.com") {
                    openURL(url)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom)

            // Footer
            VStack(spacing: 8) {
                Text(LegalContent.copyright)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    Button("Privacy Policy") {
                        openPrivacyPolicy()
                    }
                    .buttonStyle(.link)

                    Button("Support") {
                        openSupport()
                    }
                    .buttonStyle(.link)

                    Button("Website") {
                        openWebsite()
                    }
                    .buttonStyle(.link)
                }
                .font(.caption)
            }

            // Close button
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.escape)
            }
        }
        .padding(24)
        .frame(width: 400, height: 600)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .background(CentralizedTheme.shared.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("About FinanceMate")
    }

    // MARK: - Helper Methods

    private func openPrivacyPolicy() {
        let privacyPolicyContent = """
        FinanceMate Privacy Policy

        Last updated: June 2025

        PRIVACY & DATA PROTECTION
        =========================

        Your privacy is important to us. FinanceMate is designed with privacy by design principles:

        LOCAL DATA STORAGE
        • All financial documents are processed locally on your device
        • No financial data is transmitted to external servers without your explicit consent
        • Documents remain encrypted on your local storage

        AUTHENTICATION
        • We use industry-standard OAuth for secure authentication
        • Authentication tokens are stored securely in your system keychain
        • No passwords are stored by FinanceMate

        AI PROCESSING
        • AI analysis is performed with privacy-preserving techniques
        • When using cloud AI services, data is transmitted over encrypted connections
        • You control which AI providers to use through API key configuration

        CONTACT
        For privacy questions, contact: privacy@financemate.app

        This is the production privacy policy.
        """

        showTextDocument(title: "Privacy Policy", content: privacyPolicyContent)
    }

    private func openSupport() {
        let supportContent = """
        FinanceMate Support

        GET HELP & SUPPORT
        ==================

        COMMON ISSUES
        • Document upload problems: Check file format (PDF, JPG, PNG supported)
        • AI analysis errors: Verify API keys in Settings > API Configuration
        • Export issues: Ensure you have write permissions to the destination folder

        SYSTEM REQUIREMENTS
        • macOS 14.0 or later
        • 8GB RAM recommended for optimal performance
        • Internet connection for AI analysis features

        TROUBLESHOOTING
        1. Restart the application
        2. Check system permissions in System Preferences > Privacy & Security
        3. Verify API key configuration in Settings
        4. Clear application cache if performance issues occur

        CONTACT SUPPORT
        • Email: support@financemate.app
        • Response time: 24-48 hours
        • Include your system version and error details

        COMMUNITY
        • GitHub: github.com/financemate/issues
        • Documentation: financemate.app/docs

        This is the production support page.
        """

        showTextDocument(title: "Support", content: supportContent)
    }

    private func openWebsite() {
        let websiteContent = """
        FinanceMate Website Information

        ABOUT FINANCEMATE
        =================

        FinanceMate is an AI-powered financial document management application designed for macOS.

        KEY FEATURES
        • Intelligent document processing with OCR
        • AI-powered financial analysis and insights
        • Multi-LLM support (OpenAI, Anthropic, Google, Perplexity)
        • Secure local storage with cloud sync options
        • Professional reporting and export capabilities
        • Co-Pilot assistant for financial guidance

        WEBSITE
        Production website: financemate.app (coming soon)
        GitHub: github.com/financemate

        CONTACT
        • General inquiries: hello@financemate.app
        • Business partnerships: business@financemate.app
        • Press inquiries: press@financemate.app

        FOLLOW US
        • Twitter: @FinanceMateApp
        • LinkedIn: FinanceMate

        This is the production version of FinanceMate.
        """

        showTextDocument(title: "Website Information", content: websiteContent)
    }

    private func showTextDocument(title: String, content: String) {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.title = title
        panel.center()
        panel.isReleasedWhenClosed = false

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false

        let textView = NSTextView()
        textView.string = content
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.textContainerInset = NSSize(width: 10, height: 10)

        scrollView.documentView = textView
        panel.contentView = scrollView

        panel.makeKeyAndOrderFront(nil)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(CentralizedTheme.shared.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 350, height: 500)
    }
}
