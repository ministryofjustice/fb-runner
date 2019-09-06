module Components
  class Text < Component
    def to_hash
      {
        "_id": id,
        "_type": "text",
        "errors": {
          "pattern": {
            "inline": "Your answer should be 7 numbers",
            "summary": "Your answer should be 7 numbers"
          },
          "required": {
            "inline": "Enter a MAAT number",
            "summary": "Enter a MAAT number"
          }
        },
        "label": label,
        "name": name,
        "repeatable": true,
        "repeatableAdd": "Add another MAAT number",
        "repeatableHeading": "MAAT number",
        "repeatableLede": "Issued with the original application, 7 numbers (for example, 6123456)",
        "repeatableMaximum": 10,
        "validation": {
          "pattern": "^\\d{7}$",
          "required": true
        },
        "widthClassInput": "one-quarter",
        "classes": classes,
        "value": value
      }
    end

    private

    def classes
      if post? && !valid?
        "govuk-input--error"
      else
        ""
      end
    end
  end
end
