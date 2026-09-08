import Foundation

struct MealDetailMapper {
    static func mapSummary(_ dto: MealSummaryDTO) -> MealSummary {
        let url: URL?
        if let thumb = dto.strMealThumb, !thumb.trimmingCharacters(in: .whitespaces).isEmpty {
            url = URL(string: thumb)
        } else {
            url = nil
        }
        return MealSummary(
            id: dto.idMeal,
            name: dto.strMeal.trimmingCharacters(in: .whitespacesAndNewlines),
            thumbnailURL: url
        )
    }
    
    static func mapDetail(_ dto: MealDetailDTO) -> MealDetail {
        let ingredients = normalizeIngredients(dto)
        let tags = normalizeTags(dto.strTags)
        
        let thumbURL = safeURL(from: dto.strMealThumb)
        let youtubeURL = safeURL(from: dto.strYoutube)
        let sourceURL = safeURL(from: dto.strSource)
        
        return MealDetail(
            id: dto.idMeal,
            name: dto.strMeal.trimmingCharacters(in: .whitespacesAndNewlines),
            category: (dto.strCategory ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            area: (dto.strArea ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            instructions: (dto.strInstructions ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            thumbnailURL: thumbURL,
            tags: tags,
            youtubeURL: youtubeURL,
            sourceURL: sourceURL,
            ingredients: ingredients
        )
    }
    
    static func normalizeIngredients(_ dto: MealDetailDTO) -> [IngredientItem] {
        let rawPairs: [(String?, String?)] = [
            (dto.strIngredient1, dto.strMeasure1),
            (dto.strIngredient2, dto.strMeasure2),
            (dto.strIngredient3, dto.strMeasure3),
            (dto.strIngredient4, dto.strMeasure4),
            (dto.strIngredient5, dto.strMeasure5),
            (dto.strIngredient6, dto.strMeasure6),
            (dto.strIngredient7, dto.strMeasure7),
            (dto.strIngredient8, dto.strMeasure8),
            (dto.strIngredient9, dto.strMeasure9),
            (dto.strIngredient10, dto.strMeasure10),
            (dto.strIngredient11, dto.strMeasure11),
            (dto.strIngredient12, dto.strMeasure12),
            (dto.strIngredient13, dto.strMeasure13),
            (dto.strIngredient14, dto.strMeasure14),
            (dto.strIngredient15, dto.strMeasure15),
            (dto.strIngredient16, dto.strMeasure16),
            (dto.strIngredient17, dto.strMeasure17),
            (dto.strIngredient18, dto.strMeasure18),
            (dto.strIngredient19, dto.strMeasure19),
            (dto.strIngredient20, dto.strMeasure20)
        ]
        
        var results: [IngredientItem] = []
        for (rawIng, rawMeasure) in rawPairs {
            guard let ing = rawIng?.trimmingCharacters(in: .whitespacesAndNewlines), !ing.isEmpty else {
                continue
            }
            let measure = rawMeasure?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            results.append(IngredientItem(name: ing, measure: measure))
        }
        return results
    }
    
    static func normalizeTags(_ rawTags: String?) -> [String] {
        guard let raw = rawTags?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return []
        }
        return raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private static func safeURL(from string: String?) -> URL? {
        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !string.isEmpty,
              let url = URL(string: string),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            return nil
        }
        return url
    }
}
