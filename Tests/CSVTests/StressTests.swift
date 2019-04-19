import XCTest
import CSV

final class StressTests: XCTestCase {
    let codingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom([78, 65]))
    let data: Data = {
        let string: String
        if let envVar = ProcessInfo.processInfo.environment["CSV_STRESS_TEST_DATA"] { string = "file:" + envVar }
        else { string = "https://drive.google.com/uc?export=download&id=1_9On2-nsBQIw3JiY43sWbrF8EjrqrR4U" }
        print(string)
        let url = URL(string: string)!
        return try! Data(contentsOf: url)
    }()

    func testMeasureAsyncParsing() {
        var parser = Parser(onHeader: { _ in return }, onCell: { _, _ in return })
        let csv = Array(data)

        // Baseline: 4.630
        measure {
            parser.parse(csv)
        }
    }

    func testMeasureSyncParsing() {
        let parser = SyncParser()
        let csv = Array(data)

        // Baseline: 10.825
        // Time to beat: 9.142
        measure {
            _ = parser.parse(csv)
        }
    }

    func testMeasureAsyncSerialize() {
        var serializer = Serializer(onRow: { _ in return })
        let csv = Array(data)
        let parsed = SyncParser().parse(csv)

        // Baseline: 18.957
        // Time to beat: 11.932
        measure {
            serializer.serialize(parsed)
        }
    }

    func testMeasureSyncSerialize() {
        let serializer = SyncSerializer()
        let csv = Array(data)
        let parsed = SyncParser().parse(csv)

        // Baseline: 18.047
        // Time to beat: 11.932
        measure {
            _ = serializer.serialize(parsed)
        }
    }

    func testMeasureAsyncDecoding() {
        let decoder = CSVDecoder(decodingOptions: self.codingOptions)

        // Baseline: 14.347
        measure {
            do {
                let async = decoder.async(
                    for: Response.self,
                    length: self.data.count,
                    { _ in return }
                )
                try async.decode(data)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

fileprivate struct Response: Codable, Equatable {
    let Respondent: Int
    let Hobby: Bool
    let OpenSource: Bool
    let Country: String
    let Student: String
    let Employment: String
    let FormalEducation: String
    let UndergradMajor: String?
    let CompanySize: String
    let DevType: String
    let YearsCoding: String
    let YearsCodingProf: String?
    let JobSatisfaction: String?
    let CareerSatisfaction: String?
    let HopeFiveYears: String?
    let JobSearchStatus: String?
    let LastNewJob: String?
    let AssessJob1: Int?
    let AssessJob2: Int?
    let AssessJob3: Int?
    let AssessJob4: Int?
    let AssessJob5: Int?
    let AssessJob6: Int?
    let AssessJob7: Int?
    let AssessJob8: Int?
    let AssessJob9: Int?
    let AssessJob10: Int?
    let AssessBenefits1: Int?
    let AssessBenefits2: Int?
    let AssessBenefits3: Int?
    let AssessBenefits4: Int?
    let AssessBenefits5: Int?
    let AssessBenefits6: Int?
    let AssessBenefits7: Int?
    let AssessBenefits8: Int?
    let AssessBenefits9: Int?
    let AssessBenefits10: Int?
    let AssessBenefits11: Int?
    let JobContactPriorities1: Int?
    let JobContactPriorities2: Int?
    let JobContactPriorities3: Int?
    let JobContactPriorities4: Int?
    let JobContactPriorities5: Int?
    let JobEmailPriorities1: Int?
    let JobEmailPriorities2: Int?
    let JobEmailPriorities3: Int?
    let JobEmailPriorities4: Int?
    let JobEmailPriorities5: Int?
    let JobEmailPriorities6: Int?
    let JobEmailPriorities7: Int?
    let UpdateCV: String?
    let Currency: String?
    let Salary: Float?
    let SalaryType: String?
    let ConvertedSalary: String?
    let CurrencySymbol: String?
    let CommunicationTools: String?
    let TimeFullyProductive: String?
    let EducationTypes: String?
    let SelfTaughtTypes: String?
    let TimeAfterBootcamp: String?
    let HackathonReasons: String?
    let AgreeDisagree1: String?
    let AgreeDisagree2: String?
    let AgreeDisagree3: String?
    let LanguageWorkedWith: String?
    let LanguageDesireNextYear: String?
    let DatabaseWorkedWith: String?
    let DatabaseDesireNextYear: String?
    let PlatformWorkedWith: String?
    let PlatformDesireNextYear: String?
    let FrameworkWorkedWith: String?
    let FrameworkDesireNextYear: String?
    let IDE: String?
    let OperatingSystem: String?
    let NumberMonitors: String?
    let Methodology: String?
    let VersionControl: String?
    let CheckInCode: String?
    let AdBlocker: String?
    let AdBlockerDisable: String?
    let AdBlockerReasons: String?
    let AdsAgreeDisagree1: String?
    let AdsAgreeDisagree2: String?
    let AdsAgreeDisagree3: String?
    let AdsActions: String?
    let AdsPriorities1: Int?
    let AdsPriorities2: Int?
    let AdsPriorities3: Int?
    let AdsPriorities4: Int?
    let AdsPriorities5: Int?
    let AdsPriorities6: Int?
    let AdsPriorities7: Int?
    let AIDangerous: String?
    let AIInteresting: String?
    let AIResponsible: String?
    let AIFuture: String?
    let EthicsChoice: String?
    let EthicsReport: String?
    let EthicsResponsible: String?
    let EthicalImplications: String?
    let StackOverflowRecommend: String?
    let StackOverflowVisit: String?
    let StackOverflowHasAccount: String?
    let StackOverflowParticipate: String?
    let StackOverflowJobs: String?
    let StackOverflowDevStory: String?
    let StackOverflowJobsRecommend: String?
    let StackOverflowConsiderMember: String?
    let HypotheticalTools1: String?
    let HypotheticalTools2: String?
    let HypotheticalTools3: String?
    let HypotheticalTools4: String?
    let HypotheticalTools5: String?
    let WakeTime: String?
    let HoursComputer: String?
    let HoursOutside: String?
    let SkipMeals: String?
    let ErgonomicDevices: String?
    let Exercise: String?
    let Gender: String?
    let SexualOrientation: String?
    let EducationParents: String?
    let RaceEthnicity: String?
    let Age: String?
    let Dependents: Bool?
    let MilitaryUS: Bool?
    let SurveyTooLong: String?
    let SurveyEasy: String
}
