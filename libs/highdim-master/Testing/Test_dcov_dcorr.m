% xUnit framework required
% https://psexton.github.io/matlab-xunit/

% energy package 1.6.2
% > dcov(c(1,2,3,4),c(1,1,2,6))
% [1] 1.118034
% > dcor(c(1,2,3,4),c(1,1,2,6))
% [1] 0.8947853
% > dcov(c(1,2,3),c(.5,2,3.4))
% [1] 0.846197
% > dcor(c(1,2,3),c(.5,2,3.4))
% [1] 0.9998217
% > dcov(c(-11,2,3),c(.5,2,3.4))
% [1] 2.258591
% > dcor(c(-11,2,3),c(.5,2,3.4))
% [1] 0.9206351

classdef Test_dcov_dcorr < TestCase
   properties
   end
   
   methods
      function self = Test_dcov_dcorr(name)
         self = self@TestCase(name);         
      end
      
      function setUp(self)
      end
      
      function test_dcov1(self)
         d = dep.dcov([1 2 3 4]',[1 1 2 6]');
         assertElementsAlmostEqual(d,1.118034,'absolute',1e-5);
      end
      
      function test_dcov2(self)
         d = dep.dcov([1 2 3]',[.5 2 3.4]');
         assertElementsAlmostEqual(d,0.846197,'absolute',1e-5);
      end
      
      function test_dcov3(self)
         d = dep.dcov([-11 2 3]',[.5 2 3.4]');
         assertElementsAlmostEqual(d,2.258591,'absolute',1e-5);
      end
      
      function test_dcorr1(self)
         d = dep.dcorr([1 2 3 4]',[1 1 2 6]');
         assertElementsAlmostEqual(d,0.8947853,'absolute',1e-5);
      end
      
      function test_dcorr2(self)
         d = dep.dcorr([1 2 3]',[.5 2 3.4]');
         assertElementsAlmostEqual(d,0.9998217,'absolute',1e-5);
      end
      
      function test_dcorr3(self)
         d = dep.dcorr([-11 2 3]',[.5 2 3.4]');
         assertElementsAlmostEqual(d,0.9206351,'absolute',1e-5);
      end
            
      function tearDown(self)
      end
   end
end