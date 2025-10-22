import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/world_clock.dart';
import '../bloc/world_clock_bloc.dart';
import '../bloc/world_clock_event.dart';
import '../bloc/world_clock_state.dart';
import '../widgets/world_clock_card.dart';
import '../widgets/world_clock_modal.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  Widget _buildWorldClockList(List<WorldClock> worldClocks) {
    return Column(
      children: [
        // Header simple
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Reloj Mundial',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Lista de relojes
        Expanded(
          child: ListView.builder(
            itemCount: worldClocks.length,
            itemBuilder: (context, index) {
              final worldClock = worldClocks[index];
              return WorldClockCard(
                worldClock: worldClock,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => BlocProvider.value(
                      value: context.read<WorldClockBloc>(),
                      child: WorldClockModal(
                        worldClock: worldClock,
                      ),
                    ),
                  ).then((_) {
                    // Cuando se cierra el modal, no necesitamos recargar los datos
                    // ya que no han cambiado
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<WorldClockBloc, WorldClockState>(
        listener: (context, state) {
          if (state is WorldClockError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorldClockLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is WorldClockError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los relojes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WorldClockBloc>().add(const LoadWorldClocks());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is WorldClockLoaded) {
            return _buildWorldClockList(state.worldClocks);
          }

          if (state is WorldClockTimeLoaded) {
            if (state.worldClocks != null) {
              return _buildWorldClockList(state.worldClocks!);
            } else {
              context.read<WorldClockBloc>().add(const LoadWorldClocks());
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }

          return const Center(
            child: Text('Estado inicial'),
          );
        },
      ),
    );
  }
}
