#!/bin/bash

# Script pour remplacer les prints par le système de logging

# Controllers
sed -i "s/print('❌/Logger.error('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('⚠️/Logger.warning('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('📡/Logger.realtime('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('🔔/Logger.realtime('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('🌍/Logger.realtime('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('📨/Logger.conversations('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('📤/Logger.conversations('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('✅/Logger.info('/g" lib/src/features/parts/presentation/controllers/*.dart
sed -i "s/print('/Logger.conversations('/g" lib/src/features/parts/presentation/controllers/*.dart

# Providers
sed -i "s/print('❌/Logger.error('/g" lib/src/core/providers/*.dart
sed -i "s/print('⚠️/Logger.warning('/g" lib/src/core/providers/*.dart
sed -i "s/print('🔔/Logger.realtime('/g" lib/src/core/providers/*.dart
sed -i "s/print('📡/Logger.realtime('/g" lib/src/core/providers/*.dart
sed -i "s/print('✅/Logger.info('/g" lib/src/core/providers/*.dart
sed -i "s/print('/Logger.conversations('/g" lib/src/core/providers/*.dart

# DataSources
sed -i "s/print('❌/Logger.error('/g" lib/src/features/parts/data/datasources/*.dart
sed -i "s/print('⚠️/Logger.warning('/g" lib/src/features/parts/data/datasources/*.dart
sed -i "s/print('✅/Logger.dataSource('/g" lib/src/features/parts/data/datasources/*.dart
sed -i "s/print('/Logger.dataSource('/g" lib/src/features/parts/data/datasources/*.dart

echo "Remplacement terminé !"