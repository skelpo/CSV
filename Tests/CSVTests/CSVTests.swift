import Bits
import XCTest
import Random
@testable import CSV

class CSVTests: XCTestCase {
    func testSpeed() {
        do {
            let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
            let data = try Data(contentsOf: url)
            
            measure {
                let _: [CSV.Column] = CSV.parse(data)
            }
            
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testRowSpeed() {
        do {
            let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
            let data = try Data(contentsOf: url)
            
            let csv: [String: [String?]] = CSV.parse(data)
            
            let next = csv.makeRows()
            
            measure {
                while let _ = next() {}
            }
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testCSVDataOrganizeSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        
        measure {
            do {
                let _: [String: [Bytes?]] = try _CSVDecoder.organize(data)
            } catch { XCTFail(error.localizedDescription) }
        }
    }
    
    func testCSVDecode()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let responses = try CSVCoder.decode(data, to: Response.self)
        XCTAssertEqual(responses.first, .test)
    }
    
    func testCSVDecodeSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        
        // 140.620
        measure {
            do {
                _ = try CSVCoder.decode(data, to: Response.self)
            } catch { XCTFail(error.localizedDescription) }
        }
    }
    
    func testCSVColumnSeralization()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)
        let _ = parsed.seralize()
    }
    
    func testCSVColumnSeralizationSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)
        
        measure {
            _ = parsed.seralize()
        }
    }
    
    func testCSVEncoding()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let fielders = try CSVCoder.decode(data, to: Response.self)
        _ = try CSVCoder.encode(fielders, boolEncoding: .custom(true: "Yes".bytes, false: "No".bytes))
    }

    func testCSVEncodingSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let fielders = try CSVCoder.decode(data, to: Response.self)

        // 17.876
        measure {
            do {
                _ = try CSVCoder.encode(fielders)
            } catch { XCTFail(error.localizedDescription) }
        }
    }
    
    func testDataToIntSpeed() {
        measure {
            guard let _ = [.one, .two, .four, .nine, .five, .seven, .six, .eight, .zero, .one, .four].int else {
                XCTFail()
                return
            }
        }
        
        XCTAssertEqual([.one, .two, .four, .nine, .five, .seven, .six, .eight, .zero, .one, .four].int, 12495768014)
    }
    
    func testBytesToStringSpeed() {
        let bytes: [UInt8] = [49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 97, 115, 100, 102, 103, 104, 106, 107, 108, 122, 120, 99, 118, 98, 110, 109]
        measure {
            do {
                for _ in 0...1_000_000 {
                    _ = try String(bytes)
                }
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
        
        guard let result = String(bytes: bytes, encoding: .utf8) else {
            XCTFail()
            return
        }
        XCTAssertEqual(String(data: Data(bytes), encoding: .utf8), result)
    }
    
    func testKeyinitSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try _CSVDecoder.organize(Data(contentsOf: url))
//        guard let row = data.makeRows()() else {
//            XCTFail()
//            return
//        }
        
        measure {
            _ = Response.makeKeys(from: data)
        }
    }
    
    static var allTests = [
        ("testSpeed", testSpeed),
        ("testRowSpeed", testRowSpeed),
        ("testCSVDataOrganizeSpeed", testCSVDataOrganizeSpeed),
        ("testCSVDecode", testCSVDecode),
        ("testCSVDecodeSpeed", testCSVDecodeSpeed),
        ("testCSVColumnSeralization", testCSVColumnSeralization),
        ("testCSVColumnSeralizationSpeed", testCSVColumnSeralizationSpeed),
        ("testCSVEncoding", testCSVEncoding),
        ("testCSVEncodingSpeed", testCSVEncodingSpeed),
        ("testDataToIntSpeed", testDataToIntSpeed)
    ]
}

struct Response: Codable, Equatable {
    static func makeKeys(from row: [String: [Bytes?]]) -> [CodingKey] {
        // return row.compactMap { cell in return Response.CodingKeys.init(stringValue: cell.key) }
        return Array(row.keys).compactMap(Response.CodingKeys.init)
    }
    
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
    let SurveyEasy: String?
    
    static let test = Response(
        Respondent: 1,
        Hobby: true,
        OpenSource: false,
        Country: "Kenya",
        Student: "No",
        Employment: "Employed part-time",
        FormalEducation: "Bachelor’s degree (BA, BS, B.Eng., etc.)",
        UndergradMajor: "Mathematics or statistics",
        CompanySize: "20 to 99 employees",
        DevType: "Full-stack developer",
        YearsCoding: "3-5 years",
        YearsCodingProf: "3-5 years",
        JobSatisfaction: "Extremely satisfied",
        CareerSatisfaction: "Extremely satisfied",
        HopeFiveYears: "Working as a founder or co-founder of my own company",
        JobSearchStatus: "I’m not actively looking, but I am open to new opportunities",
        LastNewJob: "Less than a year ago",
        AssessJob1: 10,
        AssessJob2: 7,
        AssessJob3: 8,
        AssessJob4: 1,
        AssessJob5: 2,
        AssessJob6: 5,
        AssessJob7: 3,
        AssessJob8: 4,
        AssessJob9: 9,
        AssessJob10: 6,
        AssessBenefits1: nil,
        AssessBenefits2: nil,
        AssessBenefits3: nil,
        AssessBenefits4: nil,
        AssessBenefits5: nil,
        AssessBenefits6: nil,
        AssessBenefits7: nil,
        AssessBenefits8: nil,
        AssessBenefits9: nil,
        AssessBenefits10: nil,
        AssessBenefits11: nil,
        JobContactPriorities1: 3,
        JobContactPriorities2: 1,
        JobContactPriorities3: 4,
        JobContactPriorities4: 2,
        JobContactPriorities5: 5,
        JobEmailPriorities1: 5,
        JobEmailPriorities2: 6,
        JobEmailPriorities3: 7,
        JobEmailPriorities4: 2,
        JobEmailPriorities5: 1,
        JobEmailPriorities6: 4,
        JobEmailPriorities7: 3,
        UpdateCV: "My job status or other personal status changed",
        Currency: nil,
        Salary: nil,
        SalaryType: "Monthly",
        ConvertedSalary: nil,
        CurrencySymbol: "KES",
        CommunicationTools: "Slack",
        TimeFullyProductive: "One to three months",
        EducationTypes: "Taught yourself a new language, framework, or tool without taking a formal course;Participated in a hackathon",
        SelfTaughtTypes: "The official documentation and/or standards for the technology;A book or e-book from O’Reilly, Apress, or a similar publisher;Questions & answers on Stack Overflow;Online developer communities other than Stack Overflow (ex. forums, listservs, IRC channels, etc.)",
        TimeAfterBootcamp: nil,
        HackathonReasons: "To build my professional network",
        AgreeDisagree1: "Strongly agree",
        AgreeDisagree2: "Strongly agree",
        AgreeDisagree3: "Neither Agree nor Disagree",
        LanguageWorkedWith: "JavaScript;Python;HTML;CSS",
        LanguageDesireNextYear: "JavaScript;Python;HTML;CSS",
        DatabaseWorkedWith: "Redis;SQL Server;MySQL;PostgreSQL;Amazon RDS/Aurora;Microsoft Azure (Tables, CosmosDB, SQL, etc)",
        DatabaseDesireNextYear: "Redis;SQL Server;MySQL;PostgreSQL;Amazon RDS/Aurora;Microsoft Azure (Tables, CosmosDB, SQL, etc)",
        PlatformWorkedWith: "AWS;Azure;Linux;Firebase",
        PlatformDesireNextYear: "AWS;Azure;Linux;Firebase",
        FrameworkWorkedWith: "Django;React",
        FrameworkDesireNextYear: "Django;React",
        IDE: "Komodo;Vim;Visual Studio Code",
        OperatingSystem: "Linux-based",
        NumberMonitors: "1",
        Methodology: "Agile;Scrum",
        VersionControl: "Git",
        CheckInCode: "Multiple times per day",
        AdBlocker: "Yes",
        AdBlockerDisable: "No",
        AdBlockerReasons: nil,
        AdsAgreeDisagree1: "Strongly agree",
        AdsAgreeDisagree2: "Strongly agree",
        AdsAgreeDisagree3: "Strongly agree",
        AdsActions: "Saw an online advertisement and then researched it (without clicking on the ad);Stopped going to a website because of their advertising",
        AdsPriorities1: 1,
        AdsPriorities2: 5,
        AdsPriorities3: 4,
        AdsPriorities4: 7,
        AdsPriorities5: 2,
        AdsPriorities6: 6,
        AdsPriorities7: 3,
        AIDangerous: "Artificial intelligence surpassing human intelligence (the singularity)",
        AIInteresting: "Algorithms making important decisions",
        AIResponsible: "The developers or the people creating the AI",
        AIFuture: "I'm excited about the possibilities more than worried about the dangers.",
        EthicsChoice: "No",
        EthicsReport: "Yes, and publicly",
        EthicsResponsible: "Upper management at the company/organization",
        EthicalImplications: "Yes",
        StackOverflowRecommend: "10 (Very Likely)",
        StackOverflowVisit: "Multiple times per day",
        StackOverflowHasAccount: "Yes",
        StackOverflowParticipate: "I have never participated in Q&A on Stack Overflow",
        StackOverflowJobs: "No, I knew that Stack Overflow had a jobs board but have never used or visited it",
        StackOverflowDevStory: "Yes",
        StackOverflowJobsRecommend: nil,
        StackOverflowConsiderMember: "Yes",
        HypotheticalTools1: "Extremely interested",
        HypotheticalTools2: "Extremely interested",
        HypotheticalTools3: "Extremely interested",
        HypotheticalTools4: "Extremely interested",
        HypotheticalTools5: "Extremely interested",
        WakeTime: "Between 5:00 - 6:00 AM",
        HoursComputer: "9 - 12 hours",
        HoursOutside: "1 - 2 hours",
        SkipMeals: "Never",
        ErgonomicDevices: "Standing desk",
        Exercise: "3 - 4 times per week",
        Gender: "Male",
        SexualOrientation: "Straight or heterosexual",
        EducationParents: "Bachelor’s degree (BA, BS, B.Eng., etc.)",
        RaceEthnicity: "Black or of African descent",
        Age: "25 - 34 years old",
        Dependents: true,
        MilitaryUS: nil,
        SurveyTooLong: "The survey was an appropriate length",
        SurveyEasy: "Very easy"
    )
}
