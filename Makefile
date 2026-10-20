  - name: Verify source files
    shell: bash
    run: |
      echo "=== Racine du dépôt ==="
      pwd
      ls -la
      echo "=== Fichiers du projet ==="
      find . -maxdepth 3 -type f -not -path './.git/*' | sort
      echo "=== Vérification ==="
      for file in \
        Makefile \
        control \
        Sources/Tweak.xm \
        Sources/ScannerCore.h \
        Sources/ScannerCore.mm \
        Sources/ScannerMenu.h \
        Sources/ScannerMenu.mm \
        Sources/ScriptScanner.h \
        Sources/ScriptScanner.mm \
        Sources/ExportManager.h \
        Sources/ExportManager.mm
      do
        if [ -f "$file" ]; then
          echo "OK: $file"
        else
          echo "MANQUANT: $file"
          exit 1
        fi
      done
