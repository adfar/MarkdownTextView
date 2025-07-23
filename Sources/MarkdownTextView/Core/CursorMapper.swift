import Foundation

public struct CursorMapper {
    private let syntaxTree: SyntaxTree
    
    public init(syntaxTree: SyntaxTree) {
        self.syntaxTree = syntaxTree
    }
    
    public func visualToLogicalPosition(_ visualPosition: String.Index) -> String.Index {
        // For Phase 1, we don't hide syntax markers yet, so positions are 1:1
        return visualPosition
    }
    
    public func logicalToVisualPosition(_ logicalPosition: String.Index) -> String.Index {
        // For Phase 1, we don't hide syntax markers yet, so positions are 1:1
        return logicalPosition
    }
    
    public func snapToValidPosition(_ position: String.Index) -> String.Index {
        // For now, all positions are valid in Phase 1
        return position
    }
    
    public func shouldShowMarkersAt(_ position: String.Index) -> [Range<String.Index>] {
        // Find all formatted nodes that contain this position
        var markerRanges: [Range<String.Index>] = []
        
        for node in syntaxTree.nodes {
            if case .formatted(_, let fullRange, _, let markers) = node {
                if fullRange.contains(position) {
                    markerRanges.append(contentsOf: markers)
                }
            }
        }
        
        return markerRanges
    }
    
    public func getFormattedNodeAt(_ position: String.Index) -> SyntaxNode? {
        for node in syntaxTree.nodes {
            if case .formatted = node, node.range.contains(position) {
                return node
            }
        }
        return nil
    }
}