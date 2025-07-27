# Product Requirements – PublicESG Platform

## 1. Product Overview and Value Proposition

* **Product Name:** PublicESG
* **Vision:** To simplify and democratize the creation of sustainability and integrated reports for companies of all sizes.

> **Mission:** PublicESG is a *SaaS (Software as a Service)* platform that automates the sustainability reporting lifecycle. The tool guides clients from defining their materiality to publishing an audit-ready, multilingual final report. By leveraging Artificial Intelligence, the platform drastically reduces the complexity and cost of the process, enabling companies to handle their reporting internally, eliminating the reliance on external consultants, and ensuring compliance with multiple global standards (GRI, IFRS S1/S2, SASB, etc.).

## 2. User Profiles and Permissions

The platform must support multiple access levels to ensure collaboration and data security.

* **Administrator:** Full access. Configures the company account, manages users and their permissions, defines the materiality matrix, selects reporting standards, and gives final approval for publication.
* **Data Contributor:** Restricted access. Can only input and edit data and attach evidence in their assigned sections. Cannot approve sections or generate the final report.
* **Approver/Reviewer:** Review access. Can view and approve/reject specific report sections completed by contributors. Can add comments and request corrections.
* **Viewer:** Read-only access. Can only view progress dashboards and generated reports but cannot edit or input any information.

## 3. Functional Requirements (What PublicESG MUST DO)

### 3.1. Onboarding and Materiality Definition Module

This is the starting point for any new client or new reporting cycle.

* **Initial Setup:** A wizard must guide the Administrator during the first login to input essential data: company name, industry sector (using the SASB industry classification as a basis), company size, and the report's fiscal year.
* **Materiality Matrix Tool:**
    * Implement an interactive tool for the client to create and manage their Materiality Matrix.
    * The user must be able to list their stakeholders and material topics (e.g., GHG Emissions, Water Management, Diversity and Inclusion).
    * The tool must allow scoring for each topic on two axes (e.g., "Impact on Business" vs. "Importance to Stakeholders").
    * The result should be a visually clear matrix chart, which will serve as the foundation for the next step.

### 3.2. AI-Powered Smart Report Structuring Module

This module uses the materiality assessment to create an action plan for the user.

* **Framework Selection:** After defining materiality, the platform must allow the client to select the standards/frameworks they wish to adopt (e.g., a checklist with GRI, IFRS S2, SASB, etc.).
* **Dynamic Questionnaire Generation (AI):**
    * **Input:** Material topics + Selected standards.
    * **Output:** A structured and prioritized questionnaire.
    * **Indicator Classification:** The AI must analyze the input cross-section and flag each indicator/disclosure as **mandatory** or **optional**, with clear explanations as to why.
    * **AI Text Suggestion:** For descriptive (qualitative) fields, the AI should generate text suggestions based on best practices and industry data. The generated text must be **100% editable** by the user.

### 3.3. Data Collection and Management Module

The core of the platform's information input.

* **Input Interface:** Must be clear and directional, presenting the fields to be filled in a logical order.
* **Multiple Input Formats:** Support data entry via:
    1.  Manual forms.
    2.  Uploading and parsing spreadsheets (Excel, CSV).
    3.  Attaching various file types like **photos, charts, and documents**.
* **Traceability and Auditability:**
    * **Evidence Attachment:** Each piece of data entered (quantitative or qualitative) must allow for one or more evidence documents to be attached (e.g., invoices, certificates, audit reports, screenshots).
    * **Change Log:** Every data point must have a visible audit log (who inserted/changed it, and when).
* **Legacy Report Ingestion (AI):**
    * Allow the upload of previous years' reports (PDF, .docx formats).
    * Utilize NLP (Natural Language Processing) to analyze these documents, extract relevant information (e.g., historical KPI data, described policies), and pre-fill the corresponding fields in the new report.

### 3.4. Cross-Standard Mapping Module

A high-value feature to optimize workflow.

* **Automatic Cross-Referencing:** The platform must maintain a database that maps the relationships between indicators from different standards.
* **"Fill Once, Use Everywhere" Logic:** When a user inputs a piece of information (e.g., total water consumption), the system must automatically use that single answer to fulfill all corresponding requirements in the standards selected by the client (e.g., GRI 303-5, a sector-specific SASB indicator, etc.), visually showing the user that the task has been completed for multiple standards.

### 3.5. Report Generation and Translation Module

The final deliverable of the client's work.

* **Report Export:** The final report must be exportable in a professional **PDF** format.
* **Customizable Templates:** Allow the client to customize the report with their visual identity (logo, primary colors, fonts).
* **Automated Translation (AI):**
    * After finalizing the report in its original language (e.g., English), the user must have the option to generate versions in **Portuguese** and **Spanish**.
    * The backend should integrate with an AI translation service (e.g., Google Translate API, DeepL API) that is trained or optimized for sustainability terminology.
    * The platform must allow the user to review and adjust the translation before the final export.

## 4. Non-Functional Requirements (How PublicESG MUST BE)

### 4.1. Usability and User Experience (UX)

* **Clear and Intuitive Interface:** The design must be clean, modern, and intuitive, minimizing cognitive load and guiding the user step-by-step.
* **Guides and Tooltips:** Implement tooltips and help sections that explain what each indicator means and how to calculate it.

### 4.2. Reliability and Security

* **Auto-Save:** The platform must save the user's progress automatically and asynchronously after every significant change to prevent any data loss from a closed tab or lost connection.
* **Security:** The application must follow security best practices, including:
    * Full compliance with GDPR/LGPD.
    * Encryption of all data in transit (HTTPS/TLS) and at rest.
    * Prevention against common vulnerabilities (OWASP Top 10).
    * Strict access control based on user profiles.

### 4.3. Performance and Scalability

* **Architecture:** The platform should be built on a cloud-based microservices architecture (AWS, Azure, or Google Cloud) to ensure horizontal scalability.
* **Responsiveness:** The frontend should load quickly, and backend operations (spreadsheet imports, report generation) must be processed efficiently, using queues and asynchronous workers where necessary to avoid blocking the user interface.

### 4.4. Maintainability

* **Clean and Documented Code:** The source code must be well-organized, commented, and follow the style conventions of the chosen language.
* **Modular Standards Database:** The database containing the indicators and requirements from standards (GRI, SASB, etc.) must be designed so that updating to new versions or adding new standards is a matter of configuration, not of rewriting code.

## 5. Technical Recommendations and Initial Architecture

### 5.1. Tech Stack

- **Backend**:
  - Framework: **Ruby on Rails 8**.
    - But the app must be already prepared to be an JSON API server, to support mobile apps in the future, so we must leverage service objects to wrap logic, instead of adding it to controllers.
  - Database: **PostgreSQL** (setup dev and test DBs).
  - Background jobs: Solid queue.
  - Authentication: Devise with OAuth (Google).
  - Faraday for any raw HTTP interaction.
  - Dotenv for environment variable management.

- **Frontend**:
  - UI: Tailwind.
  - Rails will handle the views for now.
  - The color scheme must be extracted from @publicesg_logo.png.

- **Automated Testing**:
  - **RSpec** for unit, integration, and system tests.
  - **FactoryBot** for test data creation.
  - **Shoulda-Matchers** for declarative model tests.
  - **WebMock** to mock/block external HTTP requests.
  - **Capybara + Turbo helpers** for E2E tests with Hotwire.
  - **SimpleCov** for coverage reporting.

- **Other**
  - Docker support as a first-class citizen (we should run everything using docker).