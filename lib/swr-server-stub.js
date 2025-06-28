// CJS + ESM compatível
function useSWR() {
    return {
      data: undefined,
      error: undefined,
      isLoading: false,
      mutate: () => Promise.resolve(),
    };
  }
  
  module.exports = {
    // named export
    useSWR,
    // default export (para quem faz import def)
    default: useSWR,
  };
  