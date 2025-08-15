sequenceDiagram
    participant Client
    participant Calculator
    participant TimezoneProcessor
    participant DSTProcessor
    participant SolarTimeProcessor
    participant ChineseHelper
    
    Client->>Calculator: calculate(params)
    Calculator->>TimezoneProcessor: process timezone
    TimezoneProcessor->>ChineseHelper: calculate chinese info
    ChineseHelper-->>TimezoneProcessor: return chinese info
    TimezoneProcessor-->>Calculator: return timezone result
    
    Calculator->>DSTProcessor: process DST
    DSTProcessor->>ChineseHelper: calculate DST chinese info
    ChineseHelper-->>DSTProcessor: return DST chinese info
    DSTProcessor-->>Calculator: return DST result
    
    Calculator->>SolarTimeProcessor: process solar time
    SolarTimeProcessor->>ChineseHelper: calculate solar chinese info
    ChineseHelper-->>SolarTimeProcessor: return solar chinese info
    SolarTimeProcessor-->>Calculator: return solar result
    
    Calculator-->>Client: return BirthDateTimeDetailsBundle