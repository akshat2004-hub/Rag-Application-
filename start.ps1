# RAG Simulator — Start All Steps in Background Script
# Run this: .\start.ps1

# Stop any existing python processes running from the workspace virtual environment
Write-Host "Cleaning up any old RAG processes..." -ForegroundColor Yellow
Get-Process python -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*RAG Application*" } | Stop-Process -Force

Write-Host "`n🚀 Starting all 8 RAG Simulator FastAPI apps in the background..." -ForegroundColor Cyan

$apps = @(
    @{ name = "Step 1: Chunking & Postgres (Port 8000)"; dir = "backend" },
    @{ name = "Step 2: Embedding Generator (Port 8001)"; dir = "step2_embedding" },
    @{ name = "Step 3: Vector DB Sync (Port 8002)";      dir = "step3_vectordb" },
    @{ name = "Step 4: Simple RAG (Port 8003)";          dir = "step4_rag" },
    @{ name = "Step 5: Query Embedding (Port 8004)";     dir = "step5_query_embedding" },
    @{ name = "Step 6: Retrieval Exploration (Port 8005)"; dir = "step6_retrieval" },
    @{ name = "Step 7: Reranking (Port 8006)";           dir = "step7_reranker" },
    @{ name = "Step 8: Complete RAG Pipeline (Port 8007)"; dir = "step8_generation" }
)

$processes = @()

foreach ($app in $apps) {
    Write-Host "Starting $($app.name)..." -ForegroundColor Green
    
    # Start the process in the background, printing logs directly to this terminal
    $p = Start-Process -FilePath "$PSScriptRoot\venv\Scripts\python.exe" `
                       -ArgumentList "run.py" `
                       -WorkingDirectory "$PSScriptRoot\$($app.dir)" `
                       -NoNewWindow `
                       -PassThru
                       
    $processes += [PSCustomObject]@{
        Name = $app.name
        Process = $p
    }
}

Write-Host "`n✅ All 8 steps started successfully in the background!" -ForegroundColor Cyan
Write-Host "You can access the apps at:" -ForegroundColor Yellow
Write-Host "  Step 1: http://localhost:8000" -ForegroundColor Cyan
Write-Host "  Step 2: http://localhost:8001" -ForegroundColor Cyan
Write-Host "  Step 3: http://localhost:8002" -ForegroundColor Cyan
Write-Host "  Step 4: http://localhost:8003" -ForegroundColor Cyan
Write-Host "  Step 5: http://localhost:8004" -ForegroundColor Cyan
Write-Host "  Step 6: http://localhost:8005" -ForegroundColor Cyan
Write-Host "  Step 7: http://localhost:8006" -ForegroundColor Cyan
Write-Host "  Step 8: http://localhost:8007`n" -ForegroundColor Cyan

Write-Host "Press Ctrl+C to stop all servers and exit...`n" -ForegroundColor Yellow

# Handle termination gracefully
try {
    # Keep the script running to hold the terminal session
    while ($true) {
        Start-Sleep -Seconds 1
        
        # Check if any process has exited unexpectedly
        foreach ($procObj in $processes) {
            if ($procObj.Process.HasExited) {
                Write-Host "⚠️ Warning: $($procObj.Name) stopped running unexpectedly." -ForegroundColor Red
            }
        }
    }
}
finally {
    Write-Host "`n🛑 Stopping all servers..." -ForegroundColor Red
    foreach ($procObj in $processes) {
        if (!$procObj.Process.HasExited) {
            Write-Host "Stopping $($procObj.Name) (PID: $($procObj.Process.Id))..." -ForegroundColor Yellow
            Stop-Process -Id $procObj.Process.Id -Force
        }
    }
    Write-Host "All servers stopped." -ForegroundColor Red
}
