//
//  PostProcess.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import ARKit
import MetalKit
import RealityKit

final class PostProcess {
    
    enum PostProcessState {
        case on
        case off
    }
    
    private weak var arView: CustomARView?
    
    private var postProcessPipelines: [FunctionConstants: MTLComputePipelineState] = [:]
    private var postProcessState: PostProcessState = .on
    
    var selectedFilter: Filter = .heliumBlue
    
    init(arView: CustomARView) {
        self.arView = arView
        
        // Initialize and set up the render callback asynchronously
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setupRenderCallback()
        }
    }
    
    // MARK: - Post Process Switching
    
    func switchPostProcessState() {
        switch postProcessState {
        case .on:
            postProcessNone()
            postProcessState = .off
        case .off:
            setupRenderCallback()
            postProcessState = .on
        }
    }
    
    func switchPostProcessFilter(_ filter: Filter) {
        selectedFilter = filter
    }
}

extension PostProcess {
    
    private func setupRenderCallback() {
        arView?.renderCallbacks.postProcess = { [weak self] in
            guard let self = self else { return }
            self.postProcess(context: $0)
        }
    }
    
    private func postProcessNone() {
        arView?.renderCallbacks.postProcess = {
            let blitEncoder = $0.commandBuffer.makeBlitCommandEncoder()
            blitEncoder?.copy(from: $0.sourceColorTexture, to: $0.targetColorTexture)
            blitEncoder?.endEncoding()
        }
    }
    
    private func postProcess(context: ARView.PostProcessContext) {
        let postProcessPipeline: MTLComputePipelineState
        
        do {
            var constants = FunctionConstants(filterIndex: selectedFilter.rawValue, time: Float(CACurrentMediaTime()))
            postProcessPipeline = try self.postProcessPipeline(for: constants)
        } catch {
            assertionFailure("Failed to create compute pipeline state: \(error)")
            return
        }
        
        guard let encoder = context.commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        encoder.setComputePipelineState(postProcessPipeline)
        encoder.setTexture(context.sourceColorTexture, index: 0)
        encoder.setTexture(context.targetColorTexture, index: 1)
        
        let threadsPerGrid = MTLSize(width: context.sourceColorTexture.width,
                                     height: context.sourceColorTexture.height,
                                     depth: 1)
        
        let width = postProcessPipeline.threadExecutionWidth
        let height = postProcessPipeline.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSizeMake(width, height, 1)
        
        encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    
    private func postProcessPipeline(for constants: FunctionConstants) throws -> MTLComputePipelineState {
        var constants2 = constants
        let metalConstants = MTLFunctionConstantValues().do {
            $0.setConstantValue(&constants2.filterIndex, type: .int, index: 0)
            $0.setConstantValue(&constants2.time, type: .float, index: 1)
        }
        
        let function = try MetalLibLoader.library.makeFunction(name: "postProcess", constantValues: metalConstants)
        return try MetalLibLoader.mtlDevice.makeComputePipelineState(function: function)
    }
}
