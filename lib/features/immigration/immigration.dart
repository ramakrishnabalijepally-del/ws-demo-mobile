/// Immigration — design system Pattern B, assess then disclose.
///
/// Tool overview, numbered steps, result, breakdown, what to do next. **Every
/// result carries the provisional disclaimer**, which lives in the component so
/// no screen can forget it.
///
/// The CRS score itself lives in `lib/shared/` — it is calculated from the
/// candidate profile and read by the dashboard, the profile and the assistant
/// as well as here, so it cannot belong to one feature.
library;

export 'controllers/pnp_status.dart' show pnpRevealedProvider;
export 'controllers/stream_matches.dart';
export 'crs/presentation/screens/crs_screens.dart';
export 'data/mock_immigration.dart'
    show
        FederalProgram,
        PnpStream,
        Province,
        mockFederalPrograms,
        mockProvinces,
        mockRecentDraws;
export 'hub/presentation/screens/immigration_screen.dart';
export 'widgets/pnp_province_grid.dart';
export 'pnp/presentation/screens/pnp_screens.dart';
export 'pnp/presentation/screens/pnp_status_screen.dart';
export 'crs/presentation/screens/crs_calculating_screen.dart';
