import Foundation

enum Endpoint {
    private static let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    case indianMeals
    case mealDetail(id: String)
    case filterByCategory(category: String)
    case filterByIngredient(ingredient: String)
    case categoriesList
    case ingredientsList
    
    var url: URL? {
        var components = URLComponents(string: Endpoint.baseURL)
        switch self {
        case .indianMeals:
            components?.path += "/filter.php"
            components?.queryItems = [URLQueryItem(name: "a", value: "Indian")]
        case .mealDetail(let id):
            components?.path += "/lookup.php"
            components?.queryItems = [URLQueryItem(name: "i", value: id)]
        case .filterByCategory(let category):
            components?.path += "/filter.php"
            components?.queryItems = [URLQueryItem(name: "c", value: category)]
        case .filterByIngredient(let ingredient):
            components?.path += "/filter.php"
            components?.queryItems = [URLQueryItem(name: "i", value: ingredient)]
        case .categoriesList:
            components?.path += "/list.php"
            components?.queryItems = [URLQueryItem(name: "c", value: "list")]
        case .ingredientsList:
            components?.path += "/list.php"
            components?.queryItems = [URLQueryItem(name: "i", value: "list")]
        }
        return components?.url
    }
}
