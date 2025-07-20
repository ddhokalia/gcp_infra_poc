from genai_utils.helper import greet

def hello(request):
    name = request.args.get("name", "World")
    return greet(name)
