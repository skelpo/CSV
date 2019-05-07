# CSV

A pure Swift CSV parser and serializer, with related encoders and decoders for types that conform to `Codable`.

## 📦 Swift Package Manager

The `skelpo/CSV` package can be installed to any project that has an SPM manifest. Add the `.package` instance to the `dependencies` array:

```swift
.package(url: "https://github.com/skelpo/CSV.git", from: "1.0.0")
```

And add the `CSV` target to the dependencies of any target you want to use the package in:

```swift
.target(name: "App", dependencies: ["CSV"])
```

Then run `swift package update` and `swift package generate-xcodeproj` (if you are using Xcode).

## 🛠 API

You can find the generated API documentation [here](http://www.skelpo.codes/CSV/). In the mean time, here is a rundown of how the different methods if parsing and serializing work:

### Parser

Each type has a basic async version, and a sync wrapper around that. `Parser` is the core async implementation, while `SyncParser` is the wrapper for sync operations.

To create a `Parser`, you need to pass in a handler for header data and cell data. The header handler takes in a single parameter, which is a byte array (`[UInt8]`) of the header's contents. The cell handler takes in two parameters, the header for the cell, and the cell's contents. These are also both byte arrays. Both of these handlers allowing throwing.

**Note:** For you to be able to call `.parse(_:length:)`, your parser must be a variable. The method mutates internal state that you can't access. Anoying, I know. Hopefully this gets fixed in the future.

You can parse the CSV data by passing chunks of data into the `.parser(_:length:)` method, along with the total length of the CSV file that will be parsed. This allows us to parse the last chunk properly instead of never handling it.

As the data is parsed, the handlers for the parser will be called with the parsed data. The parsing method returns a type `Result<Void, ErrorList>`. This method has been marked `@discarableResult`, so you can ignore the returned value. An `ErrorList` is just a wrapper for an array of errors, which will be the errors thrown from the handler functions, if you ever throw anything from them.

Here is an example `Parser` instance:

```swift
var data: [String: [String]] = [:]

var parser = Parser(
    onHeader: { header in 
        let title = String(decoding: header, as: UTF8.self)
        data[title] = []
    },
    onCell: { header, cell in
        let title = String(decoding: header, as: UTF8.self)
        let contents = String(decoding: cell, as: UTF8.self)
        data[title, default: []].append(contents)
    }
)

let length = chunks.reduce(0) { $0 + $1.count }
for chunk in chunks {
    parser.parse(chunk, length: length)
}
```

If you want to parse a whole CSV document synchronously, you can use `SyncParser` instead. This type has two methods that both take in a byte array and return a dictionary that uses the headers as the keys and the columns are arrays of the cell data. One variation of the method returns the data as byte arrays, and the other returns strings.

```swift
let parser = SyncParser()
let data: [String: [String]] = parser.parse(csv)
```

### Serializer

List the parser types, there is an async `Serializer` type and a corrosponding `SyncSerializer` type. The `Serializer` initializer takes in a row handler, that is called when a row is serialized from the data passed in. This is used for both the header and cell rows.

The `Serializer.serialize(_:)` method takes in data in the form of a `KeyedCollection` with variaous generic constrainst. You can just pass in a dictionary of type `[String: [String]]` or `[[UInt8]: [[UInt8]]]`. The protocol is mostly for testing purposes within the package test suite.

If you serialize chunks of parsed data, you will need to make sure that the columns are all the same length in the data passed in, or the method will trap. That's another opprotunity for a PR if you want 😄.

Here is what an example `Serializer` might look like:

```swift
let parsedData = ...
var rows: [[UInt8]] = []

var serializer = Serializer { row in
    rows.append(row)
}
serializer.serialize(parsedData)

let document = rows.joined(separator: UInt8(ascii: "\n"))
```

The `SyncSerializer` takes in data just like the `Serializer`, and returns the whole serialized document as a byte array:

```swift
let parsedData = ...
let serializer = SyncSerializer()

let document = serializer.serialize(parsedData)
```

### Decoder

The `CSVDecoder` handles decoding CSV data into `Decodable` types in a sync or async way. You start by creating a `CSVDecoder` instance with a `CSVCodingOptions`. This defaults to the `.default` instance of the `CSVCodingOptions` type. Once you have a `CSVDecoder` instance, you can get `CSVSyncDecoder` or `CSVAsyncDecoder` based on your needs.

To get an async decoder, you can use the `.async(for:length:_:)` method. This method takes in the type that the CSV rows will be decoded to, the total length of the CSV document that will be decoded, and a handler that is called when a row is decoded. Then you can call `.decode(_:)` on the `CSVAsyncDecoder` instance with the data to decode. This method throws any errors that occur when decoding the data.

Here is an example of a `CSVAsyncDecoder`:

```swift
let length = chunks.reduce(0) { $0 + $1.count }
let decoder = CSVDecoder().async(for: [String: String].self, length: length) { row in
    database.insert(into: "table").values(row).run()
}

for chunk in chunks {
    try decoder.decode(chunk)
}
```

There is also the `CSVSyncDecoder` that works like most of the other decoders you encounter. You can create an instance with the `.sync` computed property on the `CSVDecoder` type. The sync decoder has a `.decode(_:from:)` method that takes in the type to decode the data to and the CSV data to decode. The method then returns an array of the type passed in.

Here is an example of a `CSVSyncDecoder`:

```swift
let decoder = CSVDecoder().sync
let data = try decoder.decode([String: String].self, from: data)
```

### Encoder

Like the `CSVDecoder`, you can create a `CSVEncoder` with a `CSVCodingOptions` instance and then get a sync or async version for handling your data.

The `CSVEncoder.async(_:)` method takes in 1 parameter, which is a callback function that takes in an encoded CSV row. Then when you encode your Swift type instance, they become CSV rows and you can what you want with them.

Here is an example `CSVAsyncEncoder`:

```swift
var rows: [[UInt8]] = []
let encoder = CSVEncoder().async { row in
    rows.append(row)
}

for data in encodables {
    try encoder.encode(data)
}

let document = rows.joined(separator: UInt8(ascii: "\n"))
```

The sync encoder, as expected, takes in an array of an `Encodable` type and encodes it to a CSV document:

```swift
let encoder = CSVEncoder().sync
let document = try encoder.encode(parsedData)
```

## 📄 License

This package and anything it contains is under the [MIT license agreement](https://github.com/skelpo/CSV/blob/master/LICENSE).
