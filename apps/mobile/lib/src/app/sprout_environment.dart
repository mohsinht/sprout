/// Single build-time environment gate. Mock repositories are available only
/// when explicitly requested for a development build.
const sproutEnvironment = String.fromEnvironment(
  'SPROUT_ENV',
  defaultValue: 'production',
);

const useSproutMocks = sproutEnvironment == 'dev';
