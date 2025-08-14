extension Dictionary where Key: Hashable, Value == Optional<Any> {

    var nonNils: [Key: Any] {
        var newDict = [Key: Any]()
        self.forEach { (key, value) in
            if let value {
                newDict[key] = value
            }
        }

        return newDict
    }
}
