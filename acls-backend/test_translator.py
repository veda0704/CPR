from deep_translator import GoogleTranslator
print("Imported GoogleTranslator")
translator = GoogleTranslator(source='en', target='te')
print("Initialized translator")
result = translator.translate("Hello world")
print(f"Result: {result}")
