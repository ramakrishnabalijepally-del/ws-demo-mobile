/// Immigration — design system Pattern B, assess then disclose.
///
/// Tool overview, numbered steps, result, breakdown, what to do next. **Every
/// result carries the provisional disclaimer**, which lives in the component so
/// no screen can forget it.
///
/// The CRS constants are exported because the dashboard, the profile and the
/// assistant all render the same score — one number, one source
/// (`.agents/rules/02-structure.md` rule 2).
library;

export 'crs/presentation/screens/crs_screens.dart';
export 'data/mock_immigration.dart'
    show
        FederalProgram,
        PnpStream,
        Province,
        mockCrsBreakdown,
        mockCrsMaximum,
        mockCrsScore,
        mockFederalPrograms,
        mockProvinces,
        mockRecentDraws;
export 'hub/presentation/screens/immigration_screen.dart';
export 'pnp/presentation/screens/pnp_screens.dart';
